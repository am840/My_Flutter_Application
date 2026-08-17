
import 'package:flutter/material.dart';

import '../../data/repositories/layer_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_node.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import '../dialogs/create_node_dialog.dart';

class ListoferyarProjectDetailScreen extends StatefulWidget {
  const ListoferyarProjectDetailScreen({
    super.key,
    required this.project,
  });

  final ListoferyarProject project;

  @override
  State<ListoferyarProjectDetailScreen> createState() =>
      _ListoferyarProjectDetailScreenState();
}

class _ListoferyarProjectDetailScreenState
    extends State<ListoferyarProjectDetailScreen> {
  final LayerRepository _repository = LayerRepository();

  List<ListoferyarProjectNode> _nodes = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  List<ListoferyarProjectNode> _childrenOf(int? parentId) {
    return _nodes
        .where((node) => node.parentId == parentId)
        .toList(growable: false);
  }

  Future<void> _loadTree() async {
    setState(() => _loading = true);

    try {
      final nodes =
          await _repository.getAllByProject(widget.project.id!);

      if (!mounted) return;

      setState(() {
        _nodes = nodes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ساختار پروژه خوانده نشد: $error'),
        ),
      );
    }
  }

  Future<void> _addNode({int? parentId}) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CreateNodeDialog(
        title: parentId == null ? 'افزودن بخش اصلی' : 'افزودن زیرشاخه',
        helperText: parentId == null
            ? 'این بخش می‌تواند هر تعداد زیرشاخه داشته باشد.'
            : 'این شاخه نیز می‌تواند بدون محدودیت ادامه پیدا کند.',
      ),
    );

    if (name == null) return;

    try {
      await _repository.create(
        projectId: widget.project.id!,
        parentId: parentId,
        name: name,
      );
      await _loadTree();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('افزودن بخش انجام نشد: $error')),
      );
    }
  }

  Future<void> _renameNode(ListoferyarProjectNode node) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CreateNodeDialog(
        title: 'ویرایش نام',
        initialName: node.name,
      ),
    );

    if (name == null) return;

    try {
      await _repository.updateName(id: node.id!, name: name);
      await _loadTree();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ویرایش انجام نشد: $error')),
      );
    }
  }

  Future<void> _deleteNode(ListoferyarProjectNode node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف بخش'),
        content: Text(
          '«${node.name}» و تمام زیرشاخه‌های آن حذف شوند؟',
          style: ListoferyarTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ListoferyarColors.danger,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.delete(node.id!);
      await _loadTree();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حذف انجام نشد: $error')),
      );
    }
  }

  Widget _buildNode(ListoferyarProjectNode node, int depth) {
    final children = _childrenOf(node.id);

    return Padding(
      padding: EdgeInsets.only(
        right: depth * 12.0,
        bottom: 8,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: depth == 0
                    ? ListoferyarColors.primaryLight
                        .withValues(alpha: 0.28)
                    : ListoferyarColors.borderSoft,
              ),
              boxShadow: depth == 0
                  ? const [ListoferyarTheme.subtleShadow]
                  : const [],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: depth == 0
                          ? ListoferyarColors.surfaceBlue
                          : ListoferyarColors.surfaceTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      depth == 0
                          ? Icons.account_tree_rounded
                          : Icons.segment_rounded,
                      color: depth == 0
                          ? ListoferyarColors.primary
                          : ListoferyarColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ListoferyarTypography.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          children.isEmpty
                              ? 'بدون زیرشاخه'
                              : '${children.length} زیرشاخه مستقیم',
                          style: ListoferyarTypography.helper,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'افزودن زیرشاخه',
                    onPressed: () => _addNode(parentId: node.id),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'عملیات',
                    onSelected: (value) {
                      if (value == 'rename') {
                        _renameNode(node);
                      } else if (value == 'delete') {
                        _deleteNode(node);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text('ویرایش نام'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (children.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.only(right: 10, top: 7),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: ListoferyarColors.accent,
                    width: 1.4,
                  ),
                ),
              ),
              child: Column(
                children: children
                    .map((child) => _buildNode(child, depth + 1))
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roots = _childrenOf(null);

    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ListoferyarColors.background,
          appBar: AppBar(
            title: const Text('جزئیات پروژه'),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            actions: [
              IconButton(
                tooltip: 'بازخوانی',
                onPressed: _loading ? null : _loadTree,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: ListoferyarColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [ListoferyarTheme.softShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'پروژه',
                      style: TextStyle(
                        fontFamily: ListoferyarTypography.body,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.project.name,
                      style: const TextStyle(
                        fontFamily: ListoferyarTypography.heading,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (widget.project.contractNumber.isNotEmpty)
                          _MetaChip(
                            icon: Icons.numbers_rounded,
                            text: widget.project.contractNumber,
                          ),
                        if (widget.project.contractDate.isNotEmpty)
                          _MetaChip(
                            icon: Icons.event_rounded,
                            text: widget.project.contractDate,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ContractPanel(project: widget.project),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ساختار پروژه',
                      style: ListoferyarTypography.sectionTitle,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _addNode(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('بخش اصلی'),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ListoferyarColors.accent,
                    ),
                  ),
                )
              else if (roots.isEmpty)
                _EmptyTree(onAdd: _addNode)
              else
                ...roots.map((node) => _buildNode(node, 0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContractPanel extends StatelessWidget {
  const _ContractPanel({required this.project});

  final ListoferyarProject project;

  @override
  Widget build(BuildContext context) {
    final fields = <String, String>{
      'کارفرما': project.employer,
      'مشاور': project.consultant,
      'پیمانکار': project.contractor,
      'ناظر مقیم': project.residentSupervisor,
    }.entries.where((item) => item.value.isNotEmpty).toList();

    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ListoferyarTheme.surfaceCard(radius: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اطلاعات قرارداد',
            style: ListoferyarTypography.cardTitle,
          ),
          const SizedBox(height: 10),
          ...fields.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      item.key,
                      style: ListoferyarTypography.helper,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: ListoferyarTypography.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.17),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: ListoferyarTypography.body,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTree extends StatelessWidget {
  const _EmptyTree({required this.onAdd});

  final Future<void> Function({int? parentId}) onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 28),
      decoration: ListoferyarTheme.surfaceCard(radius: 18),
      child: Column(
        children: [
          const Icon(
            Icons.account_tree_rounded,
            size: 50,
            color: ListoferyarColors.primaryLight,
          ),
          const SizedBox(height: 10),
          const Text(
            'ساختار پروژه هنوز ایجاد نشده است',
            textAlign: TextAlign.center,
            style: ListoferyarTypography.cardTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'اولین بخش اصلی را بسازید؛ سپس برای هر بخش، هر تعداد زیرشاخه که لازم دارید ایجاد کنید.',
            textAlign: TextAlign.center,
            style: ListoferyarTypography.bodyText,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('افزودن بخش اصلی'),
          ),
        ],
      ),
    );
  }
}
