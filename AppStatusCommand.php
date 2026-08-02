<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Storage;
use Throwable;

class AppStatusCommand extends Command
{
    /**
     * A assinatura do comando no console.
     *
     * @var string
     */
    protected $signature = 'app:status';

    /**
     * A descrição do comando no console.
     *
     * @var string
     */
    protected $description = 'Verifica a saúde e a conectividade dos serviços da aplicação (Banco de Dados, Redis, Object Storage).';

    /**
     * Executa o comando do console.
     *
     * @return int
     */
    public function handle(): int
    {
        $this->components->info('Verificando o status dos serviços do SEMARH Fiscaliza');

        $checks = [
            $this->checkDatabase(),
            $this->checkRedis(),
            $this->checkObjectStorage(),
        ];

        $this->table(
            ['Serviço', 'Status', 'Detalhes'],
            $checks
        );

        // Se algum dos checks tiver status 'Falhou', o comando retorna um código de erro.
        if (in_array('Falhou', array_column($checks, 1))) {
            $this->error('Um ou mais serviços estão com problemas.');
            return Command::FAILURE;
        }

        $this->info('Todos os serviços estão operacionais.');
        return Command::SUCCESS;
    }

    /**
     * Verifica a conexão com o banco de dados.
     */
    private function checkDatabase(): array
    {
        try {
            // Tenta obter o objeto PDO para forçar uma conexão real.
            DB::connection()->getPdo();
            $dbName = DB::connection()->getDatabaseName();
            return [
                'service' => 'Banco de Dados (PostgreSQL)',
                'status' => '<fg=green>OK</>',
                'details' => "Conectado ao banco '{$dbName}'",
            ];
        } catch (Throwable $e) {
            return [
                'service' => 'Banco de Dados (PostgreSQL)',
                'status' => '<fg=red>Falhou</>',
                'details' => 'Não foi possível conectar. Verifique as credenciais e o host.',
            ];
        }
    }

    /**
     * Verifica a conexão com o Redis.
     */
    private function checkRedis(): array
    {
        try {
            // O comando PING é a forma mais simples de verificar a saúde do Redis.
            Redis::ping();
            return [
                'service' => 'Filas & Cache (Redis)',
                'status' => '<fg=green>OK</>',
                'details' => 'Conexão bem-sucedida.',
            ];
        } catch (Throwable $e) {
            return [
                'service' => 'Filas & Cache (Redis)',
                'status' => '<fg=red>Falhou</>',
                'details' => 'Não foi possível conectar. Verifique o host e a porta.',
            ];
        }
    }

    /**
     * Verifica a conexão com o serviço de Object Storage (MinIO/S3).
     */
    private function checkObjectStorage(): array
    {
        $disk = config('filesystems.default');
        $bucket = config("filesystems.disks.{$disk}.bucket");

        try {
            // Tenta uma operação não destrutiva: listar arquivos na raiz do bucket.
            // Se isso funcionar, a conexão, as credenciais e o bucket estão corretos.
            Storage::disk($disk)->files('/');

            return [
                'service' => 'Armazenamento de Arquivos (MinIO/S3)',
                'status' => '<fg=green>OK</>',
                'details' => "Conectado ao bucket '{$bucket}'",
            ];
        } catch (Throwable $e) {
            return [
                'service' => 'Armazenamento de Arquivos (MinIO/S3)',
                'status' => '<fg=red>Falhou</>',
                'details' => "Não foi possível conectar ao bucket '{$bucket}'. Verifique endpoint, credenciais e nome do bucket.",
            ];
        }
    }
}