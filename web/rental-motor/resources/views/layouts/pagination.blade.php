@if ($paginator->hasPages())
    <nav role="navigation" aria-label="Pagination Navigation" class="flex justify-center">
        <ul class="inline-flex -space-x-px">
            {{-- Previous --}}
            @if ($paginator->onFirstPage())
                <li>
                    <span class="px-3 py-2 bg-gray-200 text-gray-500 border border-gray-300 rounded-l">
                        ‹
                    </span>
                </li>
            @else
                <li>
                    <a href="{{ $paginator->previousPageUrl() }}"
                        class="px-3 py-2 bg-white text-gray-700 border border-gray-300 rounded-l hover:bg-gray-100">
                        ‹
                    </a>
                </li>
            @endif

            {{-- Numbers --}}
            @foreach ($elements as $element)
                @if (is_string($element))
                    <li>
                        <span class="px-4 py-2 bg-white text-gray-500 border border-gray-300">
                            {{ $element }}
                        </span>
                    </li>
                @endif

                @if (is_array($element))
                    @foreach ($element as $page => $url)
                        @if ($page == $paginator->currentPage())
                            <li>
                                <span class="px-4 py-2 bg-blue-600 text-white border border-blue-700">
                                    {{ $page }}
                                </span>
                            </li>
                        @else
                            <li>
                                <a href="{{ $url }}"
                                    class="px-4 py-2 bg-white text-gray-700 border border-gray-300
                                      hover:bg-blue-50 hover:text-blue-600">
                                    {{ $page }}
                                </a>
                            </li>
                        @endif
                    @endforeach
                @endif
            @endforeach

            {{-- Next --}}
            @if ($paginator->hasMorePages())
                <li>
                    <a href="{{ $paginator->nextPageUrl() }}"
                        class="px-3 py-2 bg-white text-gray-700 border border-gray-300 rounded-r hover:bg-gray-100">
                        ›
                    </a>
                </li>
            @else
                <li>
                    <span class="px-3 py-2 bg-gray-200 text-gray-500 border border-gray-300 rounded-r">
                        ›
                    </span>
                </li>
            @endif
        </ul>
    </nav>
@endif
