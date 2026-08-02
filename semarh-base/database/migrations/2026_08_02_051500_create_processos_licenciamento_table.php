<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('processos_licenciamento', function (Blueprint $table) {
            $table->id();
            $table->string('numero_pa')->unique()->index();
            $table->string('requerente');
            $table->string('tipo_licenca');
            $table->string('status')->default('EM ANÁLISE');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('processos_licenciamento');
    }
};
