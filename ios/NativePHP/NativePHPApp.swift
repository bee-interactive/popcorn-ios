import SwiftUI
import Foundation
import PHP
import Bridge
import UIKit

var output = ""

@_cdecl("pipe_php_output")
public func pipe_php_output(_ cString: UnsafePointer<CChar>?) {
    guard let cString = cString else { return }

    output += String(cString: cString)
}

@main
struct NativePHPApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        _ = preparePhpEnvironment()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func getAppSupportDir(dir: String) -> String {
        // Get the URL for the Library directory in the user domain
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first

        // Append "Application Support" to the Library directory URL
        let appSupportURL = libraryURL!.appendingPathComponent("Application Support/\(dir)")

        do {
            try FileManager.default.createDirectory(
                at: appSupportURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            // Handle the error
        }

        // If you need the path as a String
        return appSupportURL.path
    }

    private func createPhpIni() {
        let caPath = Bundle.main.path(forResource: "cacert", ofType: "pem") ?? "Path not found"

        let phpIni = """
        curl.cainfo="\(caPath)"
        openssl.cafile="\(caPath)"
        """

        let appSupportDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Application Support")

        let path = appSupportDir.appendingPathComponent("php.ini")

        // Ensure the directory exists
        do {
            try FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
            return
        }

        // Write the php.ini file
        do {
            try phpIni.write(to: path, atomically: true, encoding: .utf8)
            print("Could write to phpini")
        } catch {
            print("Could not write to phpini: \(error.localizedDescription)")
        }
    }

    private func createDatabase() {
        let fileManager = FileManager.default

        let databaseFileURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Application Support/database/database.sqlite")

        if !fileManager.fileExists(atPath: databaseFileURL.path) {
            // Create an empty SQLite file
            fileManager.createFile(
                atPath: databaseFileURL.path,
                contents: nil,
                attributes: nil
            )
        }
    }

    private func migrateDatabase() {
        _ = artisan(additionalArgs: ["migrate", "--force"])
    }
    
    private func clearCaches() {
        _ = artisan(additionalArgs: ["optimize:clear"])
    }
    
    private func storageLink() {
        _ = artisan(additionalArgs: ["storage:link"])
    }

    private func preparePhpEnvironment() -> String {
        createPhpIni()

        setenv("PHPRC", "\(getAppSupportDir(dir: "/"))/php.ini", 1)

        setupEnvironment()

        output = ""

        override_embed_module_output(pipe_php_output)

        createDatabase()

        migrateDatabase()
        
        clearCaches()
        
        storageLink()

        return output
    }

    static func laravel(request: RequestData) -> String? {
        // Convert Swift strings to C strings
        let postDataC = strdup(request.postParameters)
        let methodC = strdup(request.method)
        let uriC = strdup(request.uri)

        // Free the duplicated C strings
        defer {
            free(postDataC)
            free(methodC)
            free(uriC)
        }

        output = ""

        override_embed_module_output(pipe_php_output)

        var argv: [UnsafeMutablePointer<CChar>?] = [
            strdup("php")
        ]

        let argc = Int32(argv.count)

        let phpFilePath = Bundle.main.path(forResource: "native", ofType: "php", inDirectory: "app/vendor/nativephp/ios/src")

        print()
        print("=== FORWARDING REQUEST TO LARAVEL ===")
        print()

        setenv("REMOTE_ADDR", "0.0.0.0", 1)
        setenv("REQUEST_URI", request.uri, 1)
        setenv("REQUEST_METHOD", request.method, 1)
        setenv("SCRIPT_FILENAME", phpFilePath, 1)
        setenv("PHP_SELF", "/native.php", 1)
        setenv("HTTP_HOST", "127.0.0.1", 1)
        setenv("ASSET_URL", "php://127.0.0.1/_assets/", 1)
        setenv("NATIVEPHP_RUNNING", "true", 1)
        setenv("APP_URL", "php://127.0.0.1", 1)

        for (header, value) in request.headers {
            let formattedKey = "HTTP_" + header
                .replacingOccurrences(of: "-", with: "_")
                .uppercased()

            // Convert Swift strings to C strings
            guard let cKey = formattedKey.cString(using: .utf8),
                  let cValue = value.cString(using: .utf8) else {
                print("Failed to convert \(header) or its value to C string.")
                continue
            }

            // Set this as env so that it will get picked up in $_SERVER
            setenv(cKey, cValue, 1)
        }

        // Equivalent to PHP_EMBED_START_BLOCK
        argv.withUnsafeMutableBufferPointer { bufferPtr in
            php_embed_init(argc, bufferPtr.baseAddress)

            initialize_php_with_request(postDataC, methodC, uriC)

            var fileHandle = zend_file_handle()
            zend_stream_init_filename(&fileHandle, phpFilePath)

            php_execute_script(&fileHandle)

            // Equivalent to PHP_EMBED_END_BLOCK
            php_embed_shutdown()
        }

        // Free argv strings
        argv.forEach { free($0) }

        print()
        print("=== LARAVEL FINISHED ===")
        print()

        return output
    }

    private func setupEnvironment() {
        let storageDir = getAppSupportDir(dir: "storage")
        let viewCacheDir = getAppSupportDir(dir: "storage/framework/views")
        let databaseDir = getAppSupportDir(dir: "database")

        // Ensure other directories exist
        _ = getAppSupportDir(dir: "storage/framework/sessions")
        _ = getAppSupportDir(dir: "storage/logs")
        _ = getAppSupportDir(dir: "storage/framework/cache")

        setenv("LARAVEL_STORAGE_PATH", storageDir, 1)
        setenv("VIEW_COMPILED_PATH", viewCacheDir, 1)
        setenv("DB_DATABASE", "\(databaseDir)/database.sqlite", 1)
    }

    private func artisan(additionalArgs: [String] = []) -> String {
        output = ""

        override_embed_module_output(pipe_php_output)

        var argv: [UnsafeMutablePointer<CChar>?] = [
            strdup("php")
        ]

        setenv("PHP_SELF", "artisan.php", 1)
        setenv("APP_RUNNING_IN_CONSOLE", "true", 1)

        let additionalCArgs = additionalArgs.map { strdup($0) }
        argv.append(contentsOf: additionalCArgs)

        let argc = Int32(argv.count)

        let phpFilePath = Bundle.main.path(forResource: "artisan", ofType: "php", inDirectory: "app/vendor/nativephp/ios/src")

        argv.withUnsafeMutableBufferPointer { bufferPtr in
            php_embed_init(argc, bufferPtr.baseAddress)

            var fileHandle = zend_file_handle()
            zend_stream_init_filename(&fileHandle, phpFilePath)

            php_execute_script(&fileHandle)

            php_embed_shutdown()
        }

        argv.forEach { free($0) }

        return output
    }
}
