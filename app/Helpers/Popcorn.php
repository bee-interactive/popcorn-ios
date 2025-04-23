<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Http;

class Popcorn
{
    public static function get($url = '', $token = null, $params = null)
    {
        if (session('app-access-token')) {
            $token = session('app-access-token');
        }

        $response = Http::acceptJson()->withToken($token)->get(config('services.api.url').$url);

        $data = json_decode($response->body());

        return collect($data);
    }

    public static function post($url, $params = null)
    {
        if (session('app-access-token')) {
            $token = session('app-access-token');
        }

        $response = Http::acceptJson($token)->withToken($token)->post(config('services.api.url').$url, $params);

        $data = json_decode($response->body());

        return collect($data);
    }

    public static function patch($url, $params = null)
    {
        if (session('app-access-token')) {
            $token = session('app-access-token');
        }

        $response = Http::acceptJson($token)->withToken($token)->patch(config('services.api.url').$url, $params);

        $data = json_decode($response->body());

        return collect($data);
    }

    public static function delete($url, $params = null)
    {
        if (session('app-access-token')) {
            $token = session('app-access-token');
        }

        $response = Http::acceptJson($token)->withToken($token)->delete(config('services.api.url').$url, $params);

        $data = json_decode($response->body());

        return collect($data);
    }

    public static function postWithFile($url, $fileFieldName, $file, $fileName = null, $extraParams = [])
    {
        if (session('app-access-token')) {
            $token = session('app-access-token');
        }

        $fileContents = is_string($file)
            ? file_get_contents($file)
            : file_get_contents($file->getRealPath());

        $name = $fileName ?? (is_string($file) ? basename($file) : $file->getClientOriginalName());

        $response = Http::acceptJson()
            ->withToken($token)
            ->attach($fileFieldName, $fileContents, $name)
            ->post(config('services.api.url') . $url, $extraParams);

        $data = json_decode($response->body());

        return collect($data);
    }
}
