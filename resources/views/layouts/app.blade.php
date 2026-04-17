<!DOCTYPE html>

  <html lang="en" >

<head>
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <meta name="api-token" content="{{ Auth::check() ? Auth::user()->currentAccessToken()->plainTextToken : '' }}">

  <link rel="apple-touch-icon" sizes="76x76" href="{{ asset('assets/img/apple-icon.png') }}">
  <link rel="icon" type="image/png" href="{{ asset('assets/img/favicon.png') }}">
  <title>
    Soft UI Dashboard by Creative Tim
  </title>
  <!--     Fonts and icons     -->
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
  <!-- Nucleo Icons -->
  <link href="{{ asset('assets/css/nucleo-icons.css') }}" rel="stylesheet" />
  <link href="{{ asset('assets/css/nucleo-svg.css') }}" rel="stylesheet" />
  <!-- Font Awesome Icons -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
      rel="stylesheet"
      integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
      crossorigin="anonymous" referrerpolicy="no-referrer" />
  <link href="{{ asset('assets/css/nucleo-svg.css') }}" rel="stylesheet" />
  <!-- CSS Files -->
  <link id="pagestyle" href="{{ asset('assets/css/soft-ui-dashboard.css') }}" rel="stylesheet" />
</head>

<body class="g-sidenav-show  bg-gray-100  ">
      
  @include('components.sidebar')

  <main class="main-content position-relative max-height-vh-100 h-100 mt-1 border-radius-lg ">

    @include('components.navbar')

    <div class="container-fluid py-4">
      @yield('content')
    </div>

    @include('components.footer')

  </main>

    
      <!--   Core JS Files   -->
  <script src="{{ asset('assets/js/core/popper.min.js') }}"></script>
  <script src="{{ asset('assets/js/core/bootstrap.min.js') }}"></script>
  <script src="{{ asset('assets/js/plugins/perfect-scrollbar.min.js') }}"></script>
  <script src="{{ asset('assets/js/plugins/smooth-scrollbar.min.js') }}"></script>
  <script src="{{ asset('assets/js/plugins/fullcalendar.min.js') }}"></script>
  <script src="{{ asset('assets/js/plugins/chartjs.min.js') }}"></script>
      <script>
    var win = navigator.platform.indexOf('Win') > -1;
    if (win && document.querySelector('#sidenav-scrollbar')) {
      var options = {
        damping: '0.5'
      }
      Scrollbar.init(document.querySelector('#sidenav-scrollbar'), options);
    }
  </script>

  <!-- Github buttons -->
  <script async defer src="https://buttons.github.io/buttons.js"></script>
  <!-- Control Center for Soft Dashboard: parallax effects, scripts for the example pages etc -->
  <script src="{{ asset('assets/js/soft-ui-dashboard.min.js') }}"></script>
  <script>
    // Server-Sent Events for real-time notifications
    (function () {
      const token = document.querySelector('meta[name="api-token"]');
      if (!token) return;

      const eventSource = new EventSource('/api/notifications/stream?token=' + token.content);

      eventSource.onmessage = function(event) {
        const data = JSON.parse(event.data);
        if (data.type === 'notification') {
          // Show notification
          showNotification(data.data.title, data.data.message);
          // Update notification count
          updateNotificationCount();
        }
      };

      eventSource.onerror = function() {
        console.log('SSE connection error');
      };

      function showNotification(title, message) {
        // Simple notification display
        const notification = document.createElement('div');
        notification.className = 'alert alert-info position-fixed';
        notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; max-width: 300px;';
        notification.innerHTML = '<strong>' + title + '</strong><br>' + message;
        document.body.appendChild(notification);
        setTimeout(() => notification.remove(), 5000);
      }

      function updateNotificationCount() {
        // Refresh the page or update the navbar
        location.reload();
      }
    })();
  </script>

      const channel = pusher.subscribe('reports');
      const countElement = document.querySelector('#navbar-notification-count');
      const listElement = document.querySelector('#navbar-notification-list');

      const createToast = (title, message) => {
        const toast = document.createElement('div');
        toast.className = 'position-fixed top-0 end-0 p-3';
        toast.style.zIndex = '1051';
        toast.innerHTML = `
          <div class="toast align-items-center text-bg-primary border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
              <div class="toast-body">
                <strong>${title}</strong><br>${message}
              </div>
              <button type="button" class="btn-close btn-close-white me-2 m-auto" aria-label="Close"></button>
            </div>
          </div>
        `;
        document.body.appendChild(toast);
        toast.querySelector('button')?.addEventListener('click', () => toast.remove());
        setTimeout(() => toast.remove(), 7000);
      };

      const updateBadge = (count) => {
        if (!countElement) return;
        if (count > 0) {
          countElement.textContent = count > 9 ? '9+' : count;
          countElement.style.display = 'inline-block';
        } else {
          countElement.style.display = 'none';
        }
      };

      const prependNotification = (payload) => {
        if (!listElement) return;

        const wrapper = document.createElement('li');
        wrapper.className = 'mb-2';
        wrapper.innerHTML = `
          <a class="dropdown-item border-radius-md" href="{{ url('/admin/reports') }}">
            <div class="d-flex py-1">
              <div class="avatar avatar-sm bg-gradient-primary me-3 my-auto">
                <i class="fas fa-bell text-white"></i>
              </div>
              <div class="d-flex flex-column justify-content-center">
                <h6 class="text-sm font-weight-normal mb-1">
                  <span class="font-weight-bold">${payload.title}</span>
                </h6>
                <p class="text-xs text-secondary mb-0">${payload.message}</p>
              </div>
            </div>
          </a>
        `;

        if (listElement.firstElementChild && listElement.firstElementChild.querySelector('.fa-bell-slash')) {
          listElement.innerHTML = '';
        }

        listElement.prepend(wrapper);
      };

      const handleEvent = (data) => {
        if (!data || !data.type || !data.title) {
          return;
        }

        const currentCount = countElement && countElement.textContent ? parseInt(countElement.textContent, 10) || 0 : 0;
        updateBadge(currentCount + 1);
        prependNotification(data);
        createToast(data.title, data.message);
      };

      channel.bind('report.created', handleEvent);
      channel.bind('report.status.updated', handleEvent);
    })();
  </script>
</body>

</html>