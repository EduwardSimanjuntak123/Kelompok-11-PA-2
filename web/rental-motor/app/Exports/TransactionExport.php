<?php

namespace App\Exports;

use Carbon\Carbon;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnFormatting;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Concerns\WithCustomStartCell;
use Maatwebsite\Excel\Concerns\WithTitle;
use PhpOffice\PhpSpreadsheet\Style\NumberFormat;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Maatwebsite\Excel\Events\AfterSheet;

class TransactionExport implements
    FromCollection,
    WithHeadings,
    WithStyles,
    WithColumnFormatting,
    WithEvents,
    WithCustomStartCell,
    WithTitle
{
    protected $transactions;
    protected $monthName;
    protected $year;

    public function __construct(array $transactions, string $monthName, int $year)
    {
        $this->transactions = $transactions;
        $this->monthName = $monthName;
        $this->year = $year;
    }

    public function startCell(): string
    {
        return 'A2'; // Heading mulai dari baris kedua
    }

    public function collection()
    {
        return collect($this->transactions)->map(function ($transaction) {
            return [
                'ID Transaksi'    => $transaction['id'],
                'Nama Pelanggan'  => $transaction['customer_name'],
                'Motor'           => $transaction['motor']['name'] ?? '-',
                'Tanggal Booking' => Carbon::parse($transaction['booking_date'])->format('d-m-Y'),
                'Tanggal Mulai'   => Carbon::parse($transaction['start_date'])->format('d-m-Y'),
                'Tanggal Selesai' => Carbon::parse($transaction['end_date'])->format('d-m-Y'),
                'Total Harga'     => $transaction['total_price'],
                'Status'          => ucfirst($transaction['status']),
            ];
        });
    }

    public function headings(): array
    {
        return [
            'ID Transaksi',
            'Nama Pelanggan',
            'Motor',
            'Tanggal Booking',
            'Tanggal Mulai',
            'Tanggal Selesai',
            'Total Harga',
            'Status',
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true, 'size' => 14]], // Judul di baris 1
            2 => ['font' => ['bold' => true, 'size' => 12]], // Header kolom
        ];
    }

    public function columnFormats(): array
    {
        return [
            'D' => NumberFormat::FORMAT_DATE_DDMMYYYY,
            'E' => NumberFormat::FORMAT_DATE_DDMMYYYY,
            'F' => NumberFormat::FORMAT_DATE_DDMMYYYY,
            'G' => '"Rp" #,##0',
        ];
    }

    public function registerEvents(): array
    {
        return [
            AfterSheet::class => function (AfterSheet $event) {
                $sheet = $event->sheet->getDelegate();

                // Judul di baris 1
                $sheet->setCellValue('A1', "Laporan Transaksi Bulan {$this->monthName} {$this->year}");
                $sheet->mergeCells('A1:H1');
                $sheet->getStyle('A1')->applyFromArray([
                    'font' => ['bold' => true, 'size' => 14],
                    'alignment' => ['horizontal' => 'center'],
                ]);

                // Auto-size tiap kolom
                foreach (range('A', 'H') as $col) {
                    $sheet->getColumnDimension($col)->setAutoSize(true);
                }

                // Border seluruh tabel
                $highestRow = $sheet->getHighestRow();
                $highestColumn = $sheet->getHighestColumn();
                $cellRange = "A2:{$highestColumn}{$highestRow}";

                $sheet->getStyle($cellRange)->applyFromArray([
                    'borders' => [
                        'allBorders' => [
                            'borderStyle' => Border::BORDER_THIN,
                            'color' => ['argb' => '000000'],
                        ],
                    ],
                ]);
            },
        ];
    }

    public function title(): string
    {
        return "Laporan {$this->monthName}";
    }
}
