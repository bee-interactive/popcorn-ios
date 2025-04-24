<x-layouts.app :title="__('Feed')">
    <div>
        <flux:heading size="xl" level="1">{{ __('Feed') }}</flux:heading>
        <flux:text class="mt-2">{{ __('Discover items that have been added by others') }}</flux:text>

        <div class="space-y-8 mt-12">
            @foreach($items as $dateGroup)
                <flux:card class="space-y-8 max-w-lg">
                    <div>
                        <flux:heading size="lg">{{ \Carbon\Carbon::parse($dateGroup->date)->isoFormat('LL') }}</flux:heading>
                    </div>

                    @foreach($dateGroup->users as $userGroup)
                        <div class="rounded bg-gray-50 dark:bg-[#262626]/40 pb-2">
                            <div class="p-4 pt-2">
                                <flux:heading size="sm">
                                    <div class="flex justify-between items-end mb-4">
                                        <div class="flex space-x-2">
                                            <div>
                                                <flux:profile circle :chevron="false" avatar="{{ $userGroup->user->profile_picture }}" />
                                            </div>

                                            <div class="flex flex-col">
                                                <span>{{ $userGroup->user->name }}</span>
                                                <span>&#64;{{ $userGroup->user->username }}</span>
                                            </div>
                                        </div>

                                        <flux:link class="text-sm" variant="ghost" href="{{ route('profile.show', ['username' => $userGroup->user->username]) }}">{{ __('View profile') }}</flux:link>
                                    </div>
                                </flux:heading>

                                <ul class="grid grid-cols-3 sm:grid-cols-3 md:grid-cols-4 gap-4">
                                    @foreach($userGroup->items as $item)
                                        <li>
                                            @if($item->poster_path)
                                                <img class="shadow-lg rounded w-full h-full" src="https://image.tmdb.org/t/p/w400{{ $item->poster_path }}" alt="">
                                            @else
                                                <img class="shadow-lg rounded w-full h-full" src="{{ asset('img/placeholder.jpg') }}" alt="">
                                            @endif
                                        </li>
                                    @endforeach
                                </ul>
                            </div>
                        </div>
                    @endforeach
                </flux:card>
            @endforeach
        </div>
    </div>
</x-layouts.app>
