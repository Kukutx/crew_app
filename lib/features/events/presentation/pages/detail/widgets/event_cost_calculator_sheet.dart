import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventCostCalculatorSheet extends StatefulWidget {
  final Event event;
  final AppLocalizations loc;

  const EventCostCalculatorSheet({
    super.key,
    required this.event,
    required this.loc,
  });

  @override
  State<EventCostCalculatorSheet> createState() => _EventCostCalculatorSheetState();
}

class _EventCostCalculatorSheetState extends State<EventCostCalculatorSheet> {
  late final TextEditingController _participantsCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _carpoolCtrl;
  late final TextEditingController _commissionCtrl;

  @override
  void initState() {
    super.initState();
    final participants = widget.event.currentParticipants ??
        widget.event.maxParticipants;
    final price = widget.event.price;
    _participantsCtrl = TextEditingController(
      text: participants > 0 ? participants.toString() : '4',
    );
    _feeCtrl = TextEditingController(
      text: price != null && price > 0
          ? _formatNumber(price)
          : '',
    );
    _carpoolCtrl = TextEditingController(text: '0');
    _commissionCtrl = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _participantsCtrl.dispose();
    _feeCtrl.dispose();
    _carpoolCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    final locale = widget.loc.localeName;
    final formatter = NumberFormat('#,##0.##', locale);
    return formatter.format(value);
  }

  int _parseParticipants() {
    final digitsOnly = _participantsCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  double _parseAmount(TextEditingController controller) {
    final sanitized = controller.text.replaceAll(RegExp(r'[^0-9.,-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(sanitized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final localeTag = Localizations.localeOf(context).toString();
    final participants = _parseParticipants();
    final feePerPerson = _parseAmount(_feeCtrl);
    final carpoolCost = _parseAmount(_carpoolCtrl);
    final commissionRate = _parseAmount(_commissionCtrl);

    final totalIncome = participants * feePerPerson;
    final commissionTotal = totalIncome * (commissionRate / 100);
    final netAfterCommission = totalIncome - commissionTotal;
    final netAfterCarpool = netAfterCommission - carpoolCost;
    final perPersonCarpool = participants > 0 ? carpoolCost / participants : 0;
    final perPersonNet = participants > 0 ? netAfterCarpool / participants : 0;

    final currencyFormatter = NumberFormat.currency(
      locale: localeTag,
      symbol: '¥',
      decimalDigits: 2,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.event_cost_calculator_title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                loc.event_cost_calculator_description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _participantsCtrl,
                decoration: InputDecoration(
                  labelText: loc.event_cost_calculator_participants_label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _feeCtrl,
                decoration: InputDecoration(
                  labelText: loc.event_cost_calculator_fee_label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _carpoolCtrl,
                decoration: InputDecoration(
                  labelText: loc.event_cost_calculator_carpool_label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commissionCtrl,
                decoration: InputDecoration(
                  labelText: loc.event_cost_calculator_commission_label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              _ResultRow(
                label: loc.event_cost_calculator_total_income,
                value: currencyFormatter.format(totalIncome),
              ),
              _ResultRow(
                label: loc.event_cost_calculator_commission_total,
                value: currencyFormatter.format(commissionTotal),
              ),
              _ResultRow(
                label: loc.event_cost_calculator_carpool_share,
                value: participants > 0
                    ? currencyFormatter.format(perPersonCarpool)
                    : '--',
              ),
              _ResultRow(
                label: loc.event_cost_calculator_net_total,
                value: currencyFormatter.format(netAfterCarpool),
              ),
              _ResultRow(
                label: loc.event_cost_calculator_net_per_person,
                value: participants > 0
                    ? currencyFormatter.format(perPersonNet)
                    : '--',
              ),
              const SizedBox(height: 16),
              Text(
                loc.event_cost_calculator_hint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
