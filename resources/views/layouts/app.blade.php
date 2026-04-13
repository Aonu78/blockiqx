<!DOCTYPE html>

  <html lang="en" >

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  
  <link rel="apple-touch-icon" sizes="76x76" href="https://soft-ui-dashboard-laravel.creative-tim.com/assets/img/apple-icon.png">
  <link rel="icon" type="image/png" href="https://soft-ui-dashboard-laravel.creative-tim.com/assets/img/favicon.png">
  <title>
    Soft UI Dashboard by Creative Tim
  </title>
  <!--     Fonts and icons     -->
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />
  <!-- Nucleo Icons -->
  <link href="{{ static ('assets/css/nucleo-icons.css') }}" rel="stylesheet" />
  <link href="{{ static ('assets/css/nucleo-svg.css') }}" rel="stylesheet" />
  <!-- Font Awesome Icons -->
  <script src="https://kit.fontawesome.com/42d5adcbca.js" crossorigin="anonymous"></script>
  <link href="{{ static ('assets/css/nucleo-svg.css') }}" rel="stylesheet" />
  <!-- CSS Files -->
  <link id="pagestyle" href="{{ static ('assets/css/soft-ui-dashboard.css') }}" rel="stylesheet" />
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
  <script src="{{ static ('assets/js/core/popper.min.js') }}"></script>
  <script src="{{ static ('assets/js/core/bootstrap.min.js') }}"></script>
  <script src="{{ static ('assets/js/plugins/perfect-scrollbar.min.js') }}"></script>
  <script src="{{ static ('assets/js/plugins/smooth-scrollbar.min.js') }}"></script>
  <script src="{{ static ('assets/js/plugins/fullcalendar.min.js') }}"></script>
  <script src="{{ static ('assets/js/plugins/chartjs.min.js') }}"></script>
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
  <script src="{{ static ('assets/js/soft-ui-dashboard.min.js') }}"></script>
</body>

</html>