import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/bus_timing_list_widget.dart';

class CityBusScreen extends StatefulWidget {
  const CityBusScreen({super.key});

  @override
  State<CityBusScreen> createState() => _CityBusScreenState();
}

class _CityBusScreenState extends State<CityBusScreen>
    with TickerProviderStateMixin {
  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController transactionAmountController =
      TextEditingController();

  Map<String, int>? toIITH;
  Map<String, int>? fromIITH;

  bool _isLoading = false;

  
  final ApiServices apiServices = ApiServices();

  Map<String, dynamic>? transactionDetails;
  late TabController _tabController;

  String startingPoint = "IITH";
  String destination = "Patancheru";

  List<String> startingPointOptions = ["IITH"];
  List<String> destinationOptions = ["Patancheru", "Miyapur"];

  CityBusSchedule? busSchedule;
  String? _transactionIdError;

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> fetchBus() async {
    final response = await ApiServices().getCityBusSchedule(context);
    if (response == null) {
      showError(msg: "Server Refresh Failed...");
      final res = await SharedService().getCityBusSchedule();

      setState(() {
        busSchedule = res;
        toIITH = busSchedule?.toIITH ?? {};
        fromIITH = busSchedule?.fromIITH ?? {};
      });
    } else {
      setState(() {
        busSchedule = response;
        toIITH = busSchedule?.toIITH ?? {};
        fromIITH = busSchedule?.fromIITH ?? {};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRecentTransaction();
    fetchBus();
  }

  Future<void> _fetchRecentTransaction() async {
    try {
      final result = await ApiServices().getRecentTransaction(context);
      if (result != null) {
        final user = await SharedService().getUserDetails();
        debugPrint(result['transactionId']);
        setState(() {
          transactionDetails = {
            'transactionId': result['transactionId'],
            'travelDate': result['travelDate'],
            'paymentTime': result['paymentTime'],
            'busTiming': result['busTiming'],
            'amount': result['amount'],
            'from': result['start'],
            'to': result['destination'],
            'name': user['name'],
            'email': user['email'],
          };
        });
      }
    } catch (e) {
      debugPrint("Error fetching recent transaction: $e");
    }
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose of the tab controller when the widget is removed
    super.dispose();
  }

  Future<void> submitTransactionID() async {
    FocusScope.of(context).unfocus();
    final result = await apiServices.submitTransactionID(
        transactionIdController.text,
        transactionAmountController.text,
        startingPoint,
        destination);

    final email = (await SharedService().getUserDetails())['email'];
    final name = (await SharedService().getUserDetails())['name'];

    setState(() {
      final transactionId = (result['data']).transactionId;
      final PaymentTime = result['data'].paymentTime;
      // final BusTime = result['data'].busTiming;
      final isUsed = result['data'].isUsed;

      transactionDetails = {
        'transactionId': transactionId,
        'travelDate': DateTime.now().toIso8601String().split('T').first,
        'paymentTime': PaymentTime,
        'busTiming': PaymentTime,
        'amount': transactionAmountController.text,
        'from': startingPoint,
        'to': destination,
        'name': name,
        'email': email,
        'isUsed': isUsed,
      };
    });

    _tabController.animateTo(2);
  }

  String? _validateTransactionId(String value) {
    if (!RegExp(r'^[a-zA-Z0-9]{12,35}$').hasMatch(value)) {
      return 'Transaction ID must be 12 to 35 alphanumeric characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              'Bus Shuttle',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Payment Form'),
                Tab(text: 'Bus Schedule'),
                Tab(text: 'Confirmation'),
              ],
            )),
        body: TabBarView(
          controller: _tabController,
          children: [paymentFormTab(), schedule(), showQRTab()],
        ),
      ),
    );
  }

  Column paymentFormTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: startingPoint,
                    icon: startingPointOptions.length != 1
                        ? Icon(Icons.arrow_downward)
                        : SizedBox(),
                    elevation: 16,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          startingPoint = newValue;
                        });
                      }
                    },
                    items: startingPointOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: destination,
                    icon: destinationOptions.length != 1
                        ? Icon(Icons.arrow_downward)
                        : SizedBox(),
                    elevation: 16,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          destination = newValue;
                        });
                      }
                    },
                    items: destinationOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    final temp = startingPoint;
                    startingPoint = destination;
                    destination = temp;

                    final tempOptions = startingPointOptions;
                    startingPointOptions = destinationOptions;
                    destinationOptions = tempOptions;
                  });
                },
                icon: Icon(
                  Icons.swap_vert_rounded,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Text(
            'Tap on location to change it. Use swap button to switch start and destination',
            style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: transactionAmountController,
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                hintText: 'Transaction Amount',
                filled: true,
                fillColor: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.1),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: transactionIdController,
              onChanged: (value) => {
                if (_transactionIdError != null)
                  {
                    setState(() {
                      String? isValid =
                          _validateTransactionId(transactionIdController.text);
                      _transactionIdError = isValid;
                    })
                  }
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Transaction ID',
                filled: true,
                fillColor: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.1),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (_transactionIdError != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _transactionIdError!,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onTap: () async {
                String? isValid =
                    _validateTransactionId(transactionIdController.text);

                if (isValid == null) {
                  setState(() {
                    _isLoading = true;
                  });
                  await submitTransactionID();
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  setState(() {
                    _transactionIdError = isValid;
                  });
                }
              },
              child: _isLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 30),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 8, 30, 8),
                        child: Text('Submit',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Column showQRTab() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        if (transactionDetails != null)
          Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.8),
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 20),
              // Name
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${transactionDetails?['name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Email
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${transactionDetails?['email']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Travel Date, From, To
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blueAccent.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Travel Date & Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      // '${transactionDetails?['travelDate']}',
                      DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(transactionDetails?['paymentTime'] ?? '')),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'From: ${transactionDetails?['from']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'To: ${transactionDetails?['to']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Amount Paid
              Text(
                'Amount Paid: ₹${transactionDetails?['amount']}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.8),
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              // Transaction ID
              Text(
                'Transaction ID: ${transactionDetails?['transactionId']}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.8),
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
            ],
          )
        else
          SizedBox(
            child: Text("No Recent Transaction"),
          ),
      ],
    );
  }

  Column schedule() {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BusTimingList(
                  from: startingPoint,
                  destination: destination,
                  timings: toIITH ?? {},
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: BusTimingList(
                  from: destination,
                  destination: startingPoint,
                  timings: fromIITH ?? {},
                ),
              ),
            ],
          ),
        ),
        // _buildNoteWidget(),
      ],
    );
  }
}

class FullScheduleWidget extends StatelessWidget {
  final Map<String, int> toIITH;
  final Map<String, int> fromIITH;

  const FullScheduleWidget({
    super.key,
    required this.toIITH,
    required this.fromIITH,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BusTimingList(
                  from: 'Maingate',
                  destination: 'Hostel',
                  timings: toIITH,
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: BusTimingList(
                  from: 'Hostel',
                  destination: 'Maingate',
                  timings: fromIITH,
                ),
              ),
            ],
          ),
        ),
        _buildNoteWidget(),
      ],
    );
  }

  Widget _buildNoteWidget() {
    return Text(
      '* indicates EV',
      style: GoogleFonts.inter(fontSize: 14),
    );
  }
}
