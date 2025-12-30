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
        Schema::create('recipe_ingredients', function (Blueprint $table) {
    $table->id();
    $table->foreignId('recipe_id')->constrained()->cascadeOnDelete();
    $table->string('name');              // contoh: "tepung terigu"
    $table->string('quantity')->nullable(); // contoh: "200"
    $table->string('unit')->nullable();     // contoh: "gram"
    $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recipe_ingredients');
    }
};
