<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('recipes', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();

    $table->string('title');
    $table->text('description')->nullable();
    $table->integer('prep_time_minutes')->nullable();
    $table->integer('cook_time_minutes')->nullable();
    $table->integer('servings')->nullable();

    $table->string('photo_path')->nullable(); // simpan path file
    $table->boolean('is_published')->default(true);

    $table->timestamps();

    $table->index(['title']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recipes');
    }
};
