<?php

namespace App\Http\Controllers\Feed;

use App\Helpers\Popcorn;
use Illuminate\View\View;

class FeedController
{
    public function __invoke(): View
    {
        $items = Popcorn::get('users-feed');

        return view('feed.index', [
            'items' => $items['data'],
        ]);
    }
}
