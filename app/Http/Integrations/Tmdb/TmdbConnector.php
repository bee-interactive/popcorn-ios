<?php

namespace App\Http\Integrations\Tmdb;

use Saloon\Http\Connector;
use Saloon\Traits\Plugins\AcceptsJson;

class TmdbConnector extends Connector
{
    use AcceptsJson;

    public function resolveBaseUrl(): string
    {
        return 'https://api.themoviedb.org/3';
    }

    protected function defaultHeaders(): array
    {
        return [
            'Authorization' => 'Bearer '.session('app-user')['tmdb_token'],
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ];
    }
}
