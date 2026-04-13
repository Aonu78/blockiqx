<aside class="sidenav navbar navbar-vertical navbar-expand-xs border-0 border-radius-xl my-3 fixed-start ms-3 " id="sidenav-main">
  <div class="sidenav-header">
    <i class="fas fa-times p-3 cursor-pointer text-secondary opacity-5 position-absolute end-0 top-0 d-none d-xl-none" aria-hidden="true" id="iconSidenav"></i>
    <a class="align-items-center d-flex m-0 navbar-brand text-wrap" href="{{ route('admin.dashboard') }}">
        <img src="https://soft-ui-dashboard-laravel.creative-tim.com/assets/img/logo-ct.png" class="navbar-brand-img h-100" alt="...">
        <span class="ms-3 font-weight-bold">BLOCKIQx Admin</span>
    </a>
  </div>
  <hr class="horizontal dark mt-0">
  <div class="collapse navbar-collapse  w-auto" id="sidenav-collapse-main">
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.dashboard' ? 'active' : '' }}" href="{{ route('admin.dashboard') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-home {{ Route::currentRouteName() == 'admin.dashboard' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Dashboard</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.reports' ? 'active' : '' }}" href="{{ route('admin.reports') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-file-alt {{ Route::currentRouteName() == 'admin.reports' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Reports</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.users' ? 'active' : '' }}" href="{{ route('admin.users') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-users {{ Route::currentRouteName() == 'admin.users' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Users</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.staff' ? 'active' : '' }}" href="{{ route('admin.staff') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-user-shield {{ Route::currentRouteName() == 'admin.staff' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Staff</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.analytics' ? 'active' : '' }}" href="{{ route('admin.analytics') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-chart-bar {{ Route::currentRouteName() == 'admin.analytics' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Analytics</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ Route::currentRouteName() == 'admin.map' ? 'active' : '' }}" href="{{ route('admin.map') }}">
          <div class="icon icon-shape icon-sm shadow border-radius-md bg-white text-center me-2 d-flex align-items-center justify-content-center">
            <i class="fas fa-map-marked-alt {{ Route::currentRouteName() == 'admin.map' ? 'text-white' : 'text-dark' }}" style="font-size: 12px;"></i>
          </div>
          <span class="nav-link-text ms-1">Map View</span>
        </a>
      </li>
    </ul>
  </div>
</aside>