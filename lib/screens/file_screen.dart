import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';

class FileScreen extends StatelessWidget {
  const FileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Files')),
      body: ListView.builder(
        itemCount: fileProvider.files.length,
        itemBuilder: (context, index) {
          final file = fileProvider.files[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(_getFileIcon(file.type)),
              title: Text(file.name),
              subtitle: Text(
                '${file.type.toUpperCase()} • ${file.formattedSize}',
              ),
              onTap: () => _openFile(context, file),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => _previewFile(context, file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showFileDialog(context, fileProvider, file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _confirmDelete(context, fileProvider, file),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickFile(context, fileProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openFile(BuildContext context, FileItem file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    }
  }

  void _previewFile(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${file.type.toUpperCase()}'),
            Text('Size: ${file.formattedSize}'),
            Text('Created: ${file.createdAt.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFileDialog(
    BuildContext context,
    FileProvider fileProvider, [
    FileItem? file,
  ]) {
    final isEditing = file != null;
    final nameController = TextEditingController(text: file?.name ?? '');
    final typeController = TextEditingController(text: file?.type ?? '');
    final sizeController = TextEditingController(
      text: file?.size.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit File' : 'Add File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (e.g., pdf, jpg)',
              ),
            ),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: 'Size (bytes)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final type = typeController.text.trim();
              final size = int.tryParse(sizeController.text.trim()) ?? 0;
              if (name.isEmpty || type.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and type cannot be empty'),
                  ),
                );
                return;
              }
              if (isEditing) {
                await fileProvider.updateFile(
                  file.id,
                  FileItem(
                    id: file.id,
                    name: name,
                    path: file.path,
                    type: type,
                    size: size,
                    createdAt: file.createdAt,
                    modifiedAt: DateTime.now(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File updated successfully')),
                );
              } else {
                final newFile = FileItem(
                  id: DateTime.now().toString(),
                  name: name,
                  path: '/simulated/$name',
                  type: type,
                  size: size,
                  createdAt: DateTime.now(),
                );
                await fileProvider.addFile(newFile);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File added successfully')),
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FileProvider fileProvider,
    FileItem file,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await fileProvider.deleteFile(file.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _pickFile(BuildContext context, FileProvider fileProvider) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && context.mounted) {
      PlatformFile file = result.files.first;
      String type = file.extension ?? 'unknown';
      int size = file.size;

      final newFile = FileItem(
        id: DateTime.now().toString(),
        name: file.name,
        path: file.path ?? '',
        type: type,
        size: size,
        createdAt: DateTime.now(),
      );

      await fileProvider.addFile(newFile);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File added successfully')));
    }
  }
}
