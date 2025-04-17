<?php

namespace App\Http\Controllers\Welcome;

use Illuminate\Http\RedirectResponse;

class WelcomeController
{
    public function __invoke(): RedirectResponse
    {
        if (session()->has('app-access-token')) {
            return redirect()->route('dashboard');
        } else {
            return redirect()->route('login');
        }
    }
}
