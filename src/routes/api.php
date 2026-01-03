<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\saranController;
use App\Http\Controllers\Api\TagController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\Api\RecipeController;
use App\Http\Controllers\NotificationCotroller;
use App\Http\Controllers\RecipeHistoryController;


/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/recipes', [RecipeController::class, 'index']);
Route::get('/recipes/{recipe}', [RecipeController::class, 'show']);

Route::get('/cat', [CategoryController::class, 'get']); // ✅ public
Route::get('/tags', [TagController::class, 'index']);

Route::get('/total_pengguna', [AuthController::class, 'totalPengguna']);
Route::get('/users', [AuthController::class, 'users']);

 Route::get('/admin/recipes', [RecipeController::class, 'adminIndex']);
 Route::delete('/recipes/{recipe}', [RecipeController::class, 'destroy']);

Route::get('/sarans', [saranController::class, 'index']);
Route::post('/sarans', [saranController::class, 'store']);
Route::get('/total_saran', [saranController::class, 'total']);

Route::get('/total_resep', [RecipeController::class, 'totalResep']);

Route::patch('/users/{id}', [AuthController::class, 'updateById']);
Route::put('/users/{id}', [AuthController::class, 'updateById']);

// Route::post('/recipes/{recipe}/favorite', [\App\Http\Controllers\FavoriteController::class, 'store']);
// Route::delete('/recipes/{recipe}/favorite', [\App\Http\Controllers\FavoriteController::class, 'destroy']);
// Route::get('/me/favorites', [\App\Http\Controllers\FavoriteController::class, 'index']);

    Route::get('/notifications', [NotificationCotroller::class, 'index']);
    Route::get('/notifications/{notification}', [NotificationCotroller::class, 'show']);
    Route::post('/notifications', [NotificationCotroller::class, 'store']);
    Route::put('/notifications/{notification}', [NotificationCotroller::class, 'update']);
    Route::patch('/notifications/{notification}', [NotificationCotroller::class, 'update']);
    Route::delete('/notifications/{notification}', [NotificationCotroller::class, 'destroy']);
/*
|--------------------------------------------------------------------------
| Protected Routes (auth)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::post('/recipes', [RecipeController::class, 'store']);
    Route::put('/recipes/{recipe}', [RecipeController::class, 'update']);
    Route::patch('/recipes/{recipe}', [RecipeController::class, 'update']);
    // Route::delete('/recipes/{recipe}', [RecipeController::class, 'destroy']);

    Route::get('/me/recipes', [RecipeController::class, 'myRecipes']);

    Route::post('/categories', [CategoryController::class, 'store']);
    Route::put('/categories/{category}', [CategoryController::class, 'update']);
    Route::patch('/categories/{category}', [CategoryController::class, 'update']);
    Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

    Route::post('/tags', [TagController::class, 'store']);
    Route::put('/tags/{tag}', [TagController::class, 'update']);
    Route::patch('/tags/{tag}', [TagController::class, 'update']);
    Route::delete('/tags/{tag}', [TagController::class, 'destroy']);

    Route::patch('/recipes/{recipe}/publish', [RecipeController::class, 'publish']);
    Route::patch('/recipes/{recipe}/unpublish', [RecipeController::class, 'unpublish']);

    Route::get('/me/favorites', [FavoriteController::class, 'index']);
    Route::post('/recipes/{recipe}/favorite', [FavoriteController::class, 'store']);
    Route::delete('/recipes/{recipe}/favorite', [FavoriteController::class, 'destroy']);

    Route::post('/recipes/{recipe}/history', [RecipeHistoryController::class, 'store']);
    Route::get('/users/{user_id}/history', [RecipeHistoryController::class, 'index']);
    Route::delete('/users/{user_id}/history/{recipe_id}', [RecipeHistoryController::class, 'destroy']); // optional

});
