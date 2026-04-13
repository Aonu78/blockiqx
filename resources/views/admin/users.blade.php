@extends('layouts.app')

@section('content')
    @include('components.users-table', ['users' => $users])
@endsection
