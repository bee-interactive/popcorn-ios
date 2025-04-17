<x-layouts.app :title="__('Trending')">
    <div>
        <flux:heading size="xl" level="1">{{ __('Trending') }}</flux:heading>
        <flux:text class="mt-2">{{ __('Discover items that are currently trending') }}</flux:text>

        <div class="mt-4">
            <x-elements.minimized-search-bar />
        </div>

        <div class="mt-12">
            <flux:separator text="{{ __('Elements') }}" />

            <div class="grid grid-cols-2 gap-2 gap-y-6 lg:gap-y-4 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 lg:gap-4 pt-4">
                @foreach($results as $result)
                    <div class="relative">
                        @if($result['poster_path'])
                            <img class="shadow-lg rounded w-full h-full" src="https://image.tmdb.org/t/p/w400{{ $result['poster_path'] }}" alt="">
                        @else
                            <img class="shadow-lg rounded w-full h-full" src="{{ asset('img/placeholder.jpg') }}" alt="">
                        @endif
                    </div>
                @endforeach
            </div>
        </div>
    </div>
</x-layouts.app>
