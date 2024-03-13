import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Для форматирования даты

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text File Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TextFileScreen(),
    );
  }
}

class TextFileScreen extends StatefulWidget {
  const TextFileScreen({Key? key}) : super(key: key);

  @override
  _TextFileScreenState createState() => _TextFileScreenState();
}

class _TextFileScreenState extends State<TextFileScreen> {
  DateTime selectedDate = DateTime.now();
  List<List<String>> rows = [];

  Future<void> fetchFileData(DateTime date) async {
    String formattedDate = DateFormat('dd.MM.yyyy').format(date);
    String url = 'https://www.cnb.cz/en/financial-markets/foreign-exchange-market/central-bank-exchange-rate-fixing/central-bank-exchange-rate-fixing/daily.txt?date=$formattedDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final lines = response.body.split('\n').skip(2); // Пропускаем заголовки
        setState(() {
          rows = lines.where((line) => line.isNotEmpty).map((line) {
            final cells = line.split('|');
            return cells.length == 5 ? cells : null;
          }).where((line) => line != null).cast<List<String>>().toList();
        });
      } else {
        print('Failed to load the text file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await fetchFileData(selectedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFileData(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () => _selectDate(context),
          tooltip: 'Select Date',
        ),
        title: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850]?.withOpacity(0.8), // Темно-серый на 80% прозрачный фон
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: constraints.maxWidth,
                color: Colors.grey[850]?.withOpacity(0.8), // Темно-серый на 80% прозрачный фон для таблицы
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Country', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Currency', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Code', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Rate', style: TextStyle(color: Colors.white))),
                  ],
                  rows: rows.map((row) => DataRow(
                    cells: row.map((cell) => DataCell(Text(cell, style: const TextStyle(color: Colors.white)))).toList(),
                  )).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
