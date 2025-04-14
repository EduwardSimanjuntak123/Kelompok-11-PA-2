<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

class AuthService
{
    protected $apiBaseUrl;
    protected $client;

    public function __construct()
    {
        $this->apiBaseUrl = env('GOLANG_API_URL', 'http://localhost:8080');

        // Inisialisasi Guzzle Client dengan konfigurasi dasar
        $this->client = new Client([
            'base_uri' => $this->apiBaseUrl,
            'timeout' => 10.0, // Timeout request 10 detik
        ]);
    }

    public function login($email, $password)
    {
        try {
            Log::info("Menghubungi backend Golang di {$this->apiBaseUrl}/login", [
                'email' => $email
            ]);

            $response = $this->client->post('/login', [
                'json' => [
                    'email' => $email,
                    'password' => $password,
                ],
                'headers' => [
                    'Accept' => 'application/json',
                ],
            ]);

            $statusCode = $response->getStatusCode();
            $data = json_decode($response->getBody(), true);

            Log::info("Response dari Golang (Status: {$statusCode})", ['data' => $data]);

            // Cek apakah response sukses (kode 200 atau 201) dan ada token
            if (($statusCode === 200 || $statusCode === 201) && isset($data['token']) && isset($data['user']['role'])) {
                return $data;
            } else {
                Log::error("Login gagal, respons dari Golang tidak sesuai:", ['status' => $statusCode, 'response' => $data]);
                return ['error' => 'Login gagal. Backend tidak mengembalikan token yang valid.', 'server_response' => $data];
            }

        } catch (\Exception $e) {
            Log::error("Kesalahan saat menghubungi backend Golang", [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return ['error' => 'Terjadi kesalahan saat menghubungi server Golang'];
        }
    }

}
