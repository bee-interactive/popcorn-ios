<?php

return [
    /**
     * An internal flag to indicate if the app is running in the NativePHP
     * environment. This is used to determine if the app should use the
     * NativePHP database and storage paths.
     */
    'running' => env('NATIVEPHP_RUNNING', false),

    'storage_path' => '/storage',
];
