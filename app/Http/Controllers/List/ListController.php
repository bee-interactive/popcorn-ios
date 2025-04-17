<?php

namespace App\Http\Controllers\List;

use App\Helpers\Popcorn;
use Illuminate\View\View;

class ListController
{
    public function __invoke(string $uuid): View
    {
        $wishlist = Popcorn::get('wishlists/'.$uuid);

        return view('list.index', [
            'wishlist' => (isset($wishlist['data']) ? $wishlist['data'] : abort(404)),
        ]);
    }
}
