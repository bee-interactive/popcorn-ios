<?php

namespace App\Livewire\Auth;

use App\Helpers\Popcorn;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\Rules;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('components.layouts.auth')]
class Register extends Component
{
    public string $name = '';

    public string $username = '';

    public string $email = '';

    public string $password = '';

    public string $password_confirmation = '';

    /**
     * Handle an incoming registration request.
     */
    public function register()
    {
        $validated = $this->validate([
            'name' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255'],
            'password' => ['required', 'string', 'confirmed', Rules\Password::defaults()],
        ]);

        try {
            $call = Http::post(config('services.api.url').'auth/register', [
                'name' => $validated['name'],
                'username' => $validated['username'],
                'email' => $validated['email'],
                'password' => $validated['password'],
            ]);
        } catch (\Throwable $th) {
            return redirect('/login');
        }

        $response = Http::post(config('services.api.url').'auth/login', [
            'email' => $validated['email'],
            'password' => $validated['password'],
        ]);

        if ($response->ok()) {
            $token = json_decode($response->body())->success->token;
            session(['app-access-token' => $token]);

            $user = Popcorn::post('users/me', $token);

            session(['app-user' => [
                'uuid' => $user['data']->uuid,
                'name' => $user['data']->name,
                'username' => $user['data']->username,
                'description' => $user['data']->description,
                'language' => $user['data']->language,
                'email' => $user['data']->email,
                'public_profile' => $user['data']->public_profile,
                'tmdb_token' => $user['data']->tmdb_token,
                'profile_picture' => $user['data']->profile_picture,
            ]]);

            return redirect('/');
        } else {
            return redirect('/login');
        }
    }
}
