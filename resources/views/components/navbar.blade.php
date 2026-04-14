<nav class="navbar navbar-main navbar-expand-lg px-0 mx-4 shadow-none border-radius-xl" id="navbarBlur" navbar-scroll="true">
    @php
        $currentPage = trim($__env->yieldContent('page_title', 'dashboard'));
    @endphp
    <div class="container-fluid py-1 px-3">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent mb-0 pb-0 pt-1 px-0 me-sm-6 me-5">
                <li class="breadcrumb-item text-sm"><a class="opacity-5 text-dark" href="javascript:;">Pages</a></li>
                <li class="breadcrumb-item text-sm text-dark active text-capitalize" aria-current="page">{{ $currentPage }}</li>
            </ol>
            <h6 class="font-weight-bolder mb-0 text-capitalize">{{ $currentPage }}</h6>
        </nav>
        <div class="collapse navbar-collapse mt-sm-0 mt-2 me-md-0 me-sm-4 d-flex justify-content-end" id="navbar">
            <div class="ms-md-3 pe-md-3 d-flex align-items-center">
                <div class="input-group">
                    <span class="input-group-text text-body"><i class="fas fa-search" aria-hidden="true"></i></span>
                    <input type="text" class="form-control" placeholder="Type here...">
                </div>
            </div>
            <ul class="navbar-nav justify-content-end">
                <li class="nav-item d-flex align-items-center">
                    <form action="{{ route('logout') }}" method="POST" class="mb-0">
                        @csrf
                        <button type="submit" class="btn btn-link nav-link text-body font-weight-bold px-0 mb-0">
                            <i class="fa fa-user me-sm-1"></i>
                            <span class="d-sm-inline d-none">Sign Out</span>
                        </button>
                    </form>
                </li>
                <li class="nav-item d-xl-none ps-3 d-flex align-items-center">
                    <a href="javascript:;" class="nav-link text-body p-0" id="iconNavbarSidenav">
                        <div class="sidenav-toggler-inner">
                            <i class="sidenav-toggler-line"></i>
                            <i class="sidenav-toggler-line"></i>
                            <i class="sidenav-toggler-line"></i>
                        </div>
                    </a>
                </li>
                <li class="nav-item px-3 d-flex align-items-center">
                    <a href="javascript:;" class="nav-link text-body p-0">
                        <i class="fa fa-cog fixed-plugin-button-nav cursor-pointer"></i>
                    </a>
                </li>
                <li class="nav-item dropdown pe-2 d-flex align-items-center">
                    <a href="javascript:;" class="nav-link text-body p-0 position-relative" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa fa-bell cursor-pointer"></i>
                        @if (($navbarUnreadNotificationsCount ?? 0) > 0)
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                {{ $navbarUnreadNotificationsCount > 9 ? '9+' : $navbarUnreadNotificationsCount }}
                            </span>
                        @endif
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end px-2 py-3 me-sm-n4" aria-labelledby="dropdownMenuButton" style="min-width: 22rem;">
                        <li class="px-3 pb-2">
                            <h6 class="text-sm mb-0">{{ ($navbarIsStaff ?? false) ? 'Staff notifications' : 'Admin notifications' }}</h6>
                            <p class="text-xs text-secondary mb-0">{{ ($navbarUnreadNotificationsCount ?? 0) }} unread</p>
                        </li>
                        @forelse(($navbarNotifications ?? collect()) as $notification)
                            @php($data = $notification->data)
                            <li class="mb-2">
                                <a class="dropdown-item border-radius-md" href="{{ route('notifications.open', $notification->id) }}">
                                    <div class="d-flex py-1">
                                        <div class="avatar avatar-sm bg-gradient-{{ $notification->read_at ? 'secondary' : 'primary' }} me-3 my-auto">
                                            <i class="fas fa-bell text-white"></i>
                                        </div>
                                        <div class="d-flex flex-column justify-content-center">
                                            <h6 class="text-sm font-weight-normal mb-1">
                                                <span class="font-weight-bold">{{ $data['title'] ?? 'Notification' }}</span>
                                            </h6>
                                            <p class="text-xs text-secondary mb-0">{{ $data['message'] ?? 'You have a new update.' }}</p>
                                            <p class="text-xs text-secondary mb-0">
                                                <i class="fa fa-clock me-1"></i>
                                                {{ $notification->created_at->diffForHumans() }}
                                            </p>
                                        </div>
                                    </div>
                                </a>
                            </li>
                        @empty
                            <li>
                                <div class="dropdown-item border-radius-md">
                                    <div class="d-flex py-1">
                                        <div class="avatar avatar-sm bg-gradient-secondary me-3 my-auto">
                                            <i class="fas fa-bell-slash text-white"></i>
                                        </div>
                                        <div class="d-flex flex-column justify-content-center">
                                            <h6 class="text-sm font-weight-normal mb-1">No notifications yet</h6>
                                            <p class="text-xs text-secondary mb-0">New report activity will appear here.</p>
                                        </div>
                                    </div>
                                </div>
                            </li>
                        @endforelse
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
