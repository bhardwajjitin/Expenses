import 'package:authentication/chart/chart.dart';
import 'package:authentication/widget/expenses_list/expenses_list.dart';
import 'package:authentication/widget/new_expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authentication/blueprint.dart';

class Expenses extends StatefulWidget {
  final String userid;
  const Expenses({super.key, required this.userid});
  @override
  State<Expenses> createState() {
    return _MyExpenses();
  }
}

class _MyExpenses extends State<Expenses> {
  final List<Expense> _registered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching data
    });

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users Details')
        .doc(widget.userid)
        .collection('Expenses')
        .get();

    // Convert Firestore documents to Expense objects
    final List<Expense> fetchedExpenses = querySnapshot.docs.map((doc) {
      return Expense(
        title: doc['title'],
        amount: doc['amount'],
        date: DateTime.parse(doc['Date']),
        category:
            Category.values.firstWhere((e) => e.toString() == doc['Category']),
      )..id = doc.id;
    }).toList();

    // Update the local state with fetched expenses
    setState(() {
      _registered.clear(); // Clear any existing data
      _registered.addAll(fetchedExpenses);
      _isLoading = false;
    });
  }

  void _openAddExpense() {
    showModalBottomSheet(
      // it is used to full screen the modal sheet
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) =>
          NewExpense(onAddExpense: _addExpense, userid: widget.userid),
    );
  }

  void _addExpense(Expense expense) async {
    await FirebaseFirestore.instance
        .collection('Users Details')
        .doc(widget.userid)
        .collection('Expenses')
        .doc(expense.id)
        .set({
      'title': expense.title,
      'amount': expense.amount,
      'Date': expense.date.toString(),
      'Category': expense.category.toString(),
    });

    setState(() {
      _registered.add(expense);
    });
  }

  void _removeExpense(Expense expense) async {
    final expenseIndex = _registered.indexOf(expense);
    await FirebaseFirestore.instance
        .collection('Users Details')
        .doc(widget.userid)
        .collection('Expenses')
        .doc(expense.id)
        .delete();
    setState(() {
      _registered.remove(expense);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text('Expense deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              setState(() {
                _registered.insert(expenseIndex, expense);
              });
              await FirebaseFirestore.instance
                  .collection('Users Details')
                  .doc(widget.userid)
                  .collection('Expenses')
                  .doc(expense.id)
                  .set({
                'title': expense.title,
                'amount': expense.amount,
                'Date': expense.date.toString(),
                'Category': expense.category.toString(),
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text("No Expenses Found. Start adding some!"),
    );

    if (_registered.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registered,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: _isLoading // Show CircularProgressIndicator when loading
          ? const Center(
              child: CircularProgressIndicator(), // Loading indicator
            )
          : width < 600
              ? Column(
                  children: [
                    Chart(expenses: _registered),
                    Expanded(child: mainContent),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Chart(expenses: _registered),
                    ),
                    Expanded(child: mainContent),
                  ],
                ),
      floatingActionButton: IconButton(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add),
        color: Colors.white,
        style: const ButtonStyle(
          iconSize: WidgetStatePropertyAll(40),
          backgroundColor: WidgetStatePropertyAll(
            Color.fromRGBO(186, 63, 217, 1),
          ),
        ),
      ),
      floatingActionButtonLocation: width < 600
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}
