<?php

use Illuminate\Support\Facades\Route;
// use App\Http\Controllers\CategoryControllerReal;

Route::get('/', function () {
    return view('welcome');
});

//  Route::get('/cat', [CategoryControllerReal::class, 'get']);