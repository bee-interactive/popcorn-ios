<?php

namespace App\Livewire\Users;

use Flux\Flux;
use Livewire\Component;
use App\Helpers\Popcorn;
use Livewire\WithFileUploads;

class Avatar extends Component
{
    public string $uuid;

    use WithFileUploads;

    public $width = 300;

    public $height = 300;

    public $avatar;

    public $tmdb_token;

    public $public_profile;

    public function mount()
    {
        $this->uuid = session('app-user')['uuid'];

        $this->tmdb_token = session('app-user')['tmdb_token'];

        $this->public_profile = session('app-user')['public_profile'];
    }

    public function updatedAvatar(): void
    {
        $this->validate([
            'avatar' => ['required', 'image', 'max:12288', 'dimensions:min_width=300,min_height=300'],
        ]);

        $this->avatar->storePubliclyAs('avatar-uuid', 'avatar-uuid.jpg', 'avatars');

        $this->dispatch('openModal', 'support.crop-image', [
            'temp_image' => 'avatar-uuid.jpg',
            'uuid' => 'avatar-uuid',
            'user_uuid' => $this->uuid,
            'field' => 'avatar',
            'width' => $this->width,
            'height' => $this->height,
        ]);
    }

    public function delete(): void
    {
        $user = Popcorn::post('users/' . $this->uuid . '/avatar/delete');

        session(['app-user' => [
            'uuid' => $this->uuid,
            'name' => $user['data']->name,
            'username' => $user['data']->username,
            'description' => $user['data']->description,
            'language' => $user['data']->language,
            'email' => $user['data']->email,
            'tmdb_token' => $this->tmdb_token,
            'public_profile' => $this->public_profile,
            'profile_picture' => $user['data']->profile_picture,
        ]]);

        $this->dispatch('data-updated');
        cache()->flush();

        Flux::toast(
            text: __('The image has been deleted'),
            variant: 'success',
        );
    }
}
