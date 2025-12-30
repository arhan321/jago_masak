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
        Schema::create('recipe_steps', function (Blueprint $table) {
    $table->id();
    $table->foreignId('recipe_id')->constrained()->cascadeOnDelete();
    $table->unsignedInteger('step_number');
    $table->text('instruction');
    $table->timestamps();

    $table->unique(['recipe_id', 'step_number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recipe_steps');
    }
};
