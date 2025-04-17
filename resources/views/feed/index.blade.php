<x-layouts.app :title="__('Feed')">
    <div>
        <flux:heading size="xl" level="1">{{ __('Feed') }}</flux:heading>
        <flux:text class="mt-2">{{ __('Discover items that have been added by others') }}</flux:text>

        <div class="space-y-8 mt-12">
            @foreach($items as $dateGroup)
                <div class="space-y-8 max-w-lg">
                    @foreach($dateGroup->users as $userGroup)
                        <div>
                            <flux:card class="p-4">
                                <flux:heading size="sm">
                                    <div class="flex space-x-2 mb-4">
                                        <div>
                                            <flux:profile circle :chevron="false" avatar="{{ $userGroup->user->profile_picture }}" />
                                        </div>

                                        <div class="flex flex-col">
                                            <span>{{ $userGroup->user->name }}</span>
                                            <span>&#64;{{ $userGroup->user->username }}</span>
                                        </div>
                                    </div>
                                </flux:heading>

                                <ul class="grid grid-cols-3 sm:grid-cols-3 md:grid-cols-4 gap-4">
                                    @foreach($userGroup->user->items as $item)
                                        <li>
                                            @if($item->poster_path)
                                                <img class="shadow-lg rounded w-full h-full" src="https://image.tmdb.org/t/p/w400{{ $item->poster_path }}" alt="">
                                            @else
                                                <img class="shadow-lg rounded w-full h-full" src="{{ asset('img/placeholder.jpg') }}" alt="">
                                            @endif
                                        </li>
                                    @endforeach
                                </ul>

                                <div class="flex justify-between border-t mt-6 pt-4">
                                    <flux:link class="text-sm" variant="ghost" href="{{ route('profile.show', ['username' => $userGroup->user->username]) }}">{{ __('View profile') }}</flux:link>

                                    <span class="text-sm text-gray-500">{{ \Carbon\Carbon::parse($dateGroup->date)->format('d.m.Y') }}</span>
                                </div>
                            </flux:card>
                        </div>
                    @endforeach
                </div>
            @endforeach
        </div>
    </div>
</x-layouts.app>
