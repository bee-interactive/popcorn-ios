<div class="relative" x-data="{ visible: false }" @mouseover="visible = true" @mouseleave="visible = false">
    <div class="relative h-full">
        <div x-show="visible" x-cloak x-transition:enter="transition ease-out duration-300 opacity-0"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200 opacity-100"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0" class="absolute rounded flex flex-col justify-between bg-slate-600/90 inset-0 p-4 z-20">
            <div>
                <h3 class="transition-all font-semibold duration-200 leading-4 text-white">{!! $item->name !!}</h3>

                @if($item->synopsis)
                    <div class="mt-4 border-t border-white/60 pt-4">
                        <flux:text>{!! str($item->synopsis)->limit(80) !!}</flux:text>
                    </div>
                @endif
            </div>

            <div>
                <div class="flex justify-between">
                    <div class="flex justify-start">
                        <flux:button type="link" href="{{ route('items.show', ['uuid' => $item->uuid]) }}" tooltip="{{ __('See details') }}" size="sm" icon="eye"></flux:button>
                    </div>

                    @if(!$item->watched)
                        <div class="flex justify-center">
                            <flux:button tooltip="{{ __('Mark as viewed') }}" onclick="Livewire.dispatch('openModal', { component: 'item.mark-item-as-viewed', arguments: { uuid: '{{ $item->uuid }}' }})" size="sm" icon="check-circle"></flux:button>
                        </div>
                    @endif

                    <div class="flex justify-end">
                        <flux:button tooltip="{{ __('Remove this item') }}" variant="danger" onclick="Livewire.dispatch('openModal', { component: 'item.delete-item', arguments: { uuid: '{{ $item->uuid }}' }})" size="sm" icon="trash"></flux:button>
                    </div>
                </div>
            </div>
        </div>

        @if($item->watched)
            <div class="absolute z-10 top-2 right-2">
                <flux:button variant="ghost" size="sm" class="!text-green-400 bg-green-500 fill-green-400" icon="check-circle"></flux:button>
            </div>
        @endif

        @if($item->poster_path)
            <img class="shadow-lg rounded w-full h-full" src="https://image.tmdb.org/t/p/w400{{ $item->poster_path }}" alt="">
        @else
            <img class="shadow-lg rounded w-full h-full" src="{{ asset('img/placeholder.jpg') }}" alt="">
        @endif
    </div>
</div>
