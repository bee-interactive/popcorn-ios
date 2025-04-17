<div>
    @if($wishlists->isNotEmpty() && isset($wishlists['data']))
        @foreach($wishlists['data'] as $wishlist)
            <flux:navlist.item badge="{{ ($wishlist->is_favorite ? '★' : null) }}" href="{{ route('wishlists.show', $wishlist->uuid) }}">{{ $wishlist->name }}</flux:navlist.item>
        @endforeach
    @endif
</div>
