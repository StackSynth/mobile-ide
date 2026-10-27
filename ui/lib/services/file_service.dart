import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_node.dart';

abstract class FileService {
  Future<List<FileNode>> getFileTree(String projectId);
  Future<String> readFile(String path);
  Future<void> saveFile(String path, String content);
  Future<void> createFile({required String parentPath, required String name, required bool isDirectory});
  Future<void> renameFile({required String path, required String newName});
  Future<void> deleteFile({required String path});
  Future<void> duplicateFile({required String path});
}

class MockFileService implements FileService {
  final Map<String, String> _fileContents = {
    'src/App.tsx': '''import React, { useState } from 'react';
import { Header } from './components/Header';
import { ProductCard } from './components/ProductCard';
import './App.css';

export default function App() {
  const [cartCount, setCartCount] = useState(0);

  const handleAddToCart = () => {
    setCartCount(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100">
      <Header cartCount={cartCount} />
      <main className="max-w-4xl mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold tracking-tight mb-6">
          Featured Mobile Gadgets
        </h1>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ProductCard
            title="CyberDeck Keyboard"
            price={189}
            tag="Hot"
            onAdd={handleAddToCart}
          />
          <ProductCard
            title="Holographic Field Monitor"
            price={429}
            tag="New"
            onAdd={handleAddToCart}
          />
        </div>
      </main>
    </div>
  );
}
''',
    'src/components/Header.tsx': '''import React from 'react';

interface HeaderProps {
  cartCount: number;
}

export const Header: React.FC<HeaderProps> = ({ cartCount }) => {
  return (
    <header className="sticky top-0 z-50 backdrop-blur-md bg-slate-900/80 border-b border-slate-800 px-4 py-3 flex items-center justify-between">
      <div className="flex items-center gap-2">
        <div className="w-8 h-8 rounded-lg bg-indigo-500 flex items-center justify-center font-bold text-white">
          S
        </div>
        <span className="font-semibold text-lg tracking-tight">StackSynth</span>
      </div>
      <div className="flex items-center gap-2">
        <button className="px-3 py-1.5 rounded-full bg-slate-800 text-sm font-medium hover:bg-slate-700 transition">
          Cart ({cartCount})
        </button>
      </div>
    </header>
  );
};
''',
    'src/components/ProductCard.tsx': '''import React from 'react';

interface ProductCardProps {
  title: string;
  price: number;
  tag?: string;
  onAdd: () => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({ title, price, tag, onAdd }) => {
  return (
    <div className="p-4 rounded-xl bg-slate-900 border border-slate-800 hover:border-indigo-500/50 transition">
      <div className="flex justify-between items-start mb-2">
        <h3 className="font-semibold text-base">{title}</h3>
        {tag && (
          <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400 font-medium">
            {tag}
          </span>
        )}
      </div>
      <p className="text-slate-400 text-sm mb-4">High performance tool designed for mobile development.</p>
      <div className="flex justify-between items-center">
        <span className="text-lg font-bold text-emerald-400">\${price}</span>
        <button
          onClick={onAdd}
          className="px-4 py-1.5 rounded-lg bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-500 active:scale-95 transition"
        >
          Add to Cart
        </button>
      </div>
    </div>
  );
};
''',
    'src/App.css': ''':root {
  font-family: Inter, system-ui, sans-serif;
  color-scheme: dark;
}

body {
  margin: 0;
  background-color: #030712;
}
''',
    'package.json': '''{
  "name": "react-shop-mobile",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0 --port 5173",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "lucide-react": "^0.475.0"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.7.3",
    "vite": "^6.2.0"
  }
}
''',
    'vite.config.ts': '''import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
  },
});
''',
    'README.md': '''# react-shop-mobile
Built from your phone using StackSynth Mobile IDE.
Vite + React 19 + Tailwind CSS containerized dev server.
''',
  };

  @override
  Future<List<FileNode>> getFileTree(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      FileNode(
        path: 'src',
        name: 'src',
        isDirectory: true,
        isExpanded: true,
        children: [
          FileNode(
            path: 'src/components',
            name: 'components',
            isDirectory: true,
            isExpanded: true,
            children: [
              const FileNode(
                path: 'src/components/Header.tsx',
                name: 'Header.tsx',
                gitStatus: GitFileStatus.modified,
              ),
              const FileNode(
                path: 'src/components/ProductCard.tsx',
                name: 'ProductCard.tsx',
                gitStatus: GitFileStatus.added,
              ),
            ],
          ),
          const FileNode(
            path: 'src/App.tsx',
            name: 'App.tsx',
            gitStatus: GitFileStatus.modified,
          ),
          const FileNode(
            path: 'src/App.css',
            name: 'App.css',
            gitStatus: GitFileStatus.unmodified,
          ),
        ],
      ),
      const FileNode(
        path: 'package.json',
        name: 'package.json',
        gitStatus: GitFileStatus.unmodified,
      ),
      const FileNode(
        path: 'vite.config.ts',
        name: 'vite.config.ts',
        gitStatus: GitFileStatus.unmodified,
      ),
      const FileNode(
        path: 'README.md',
        name: 'README.md',
        gitStatus: GitFileStatus.unmodified,
      ),
    ];
  }

  @override
  Future<String> readFile(String path) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _fileContents[path] ?? '// Empty file or new buffer\\n';
  }

  @override
  Future<void> saveFile(String path, String content) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fileContents[path] = content;
  }

  @override
  Future<void> createFile({
    required String parentPath,
    required String name,
    required bool isDirectory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final fullPath = parentPath.isEmpty ? name : '$parentPath/$name';
    if (!isDirectory) {
      _fileContents[fullPath] = '// New file: $name\\n';
    }
  }

  @override
  Future<void> renameFile({required String path, required String newName}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final content = _fileContents.remove(path);
    final dir = path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '';
    final newPath = dir.isEmpty ? newName : '$dir/$newName';
    if (content != null) {
      _fileContents[newPath] = content;
    }
  }

  @override
  Future<void> deleteFile({required String path}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fileContents.remove(path);
  }

  @override
  Future<void> duplicateFile({required String path}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final content = _fileContents[path] ?? '';
    final dotIndex = path.lastIndexOf('.');
    final copyPath = dotIndex != -1
        ? '${path.substring(0, dotIndex)}.copy${path.substring(dotIndex)}'
        : '$path.copy';
    _fileContents[copyPath] = content;
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return MockFileService();
});

// File Tree State Notifier
class FileTreeNotifier extends StateNotifier<AsyncValue<List<FileNode>>> {
  final FileService _service;

  FileTreeNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTree();
  }

  Future<void> loadTree() async {
    state = const AsyncValue.loading();
    try {
      final nodes = await _service.getFileTree('current');
      state = AsyncValue.data(nodes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggleExpand(String path) {
    state.whenData((nodes) {
      state = AsyncValue.data(_toggleInNodes(nodes, path));
    });
  }

  List<FileNode> _toggleInNodes(List<FileNode> nodes, String path) {
    return nodes.map((node) {
      if (node.path == path) {
        return node.copyWith(isExpanded: !node.isExpanded);
      }
      if (node.isDirectory && node.children.isNotEmpty) {
        return node.copyWith(children: _toggleInNodes(node.children, path));
      }
      return node;
    }).toList();
  }

  Future<void> createFile(String parent, String name, bool isDir) async {
    await _service.createFile(parentPath: parent, name: name, isDirectory: isDir);
    await loadTree();
  }

  Future<void> renameFile(String path, String newName) async {
    await _service.renameFile(path: path, newName: newName);
    await loadTree();
  }

  Future<void> deleteFile(String path) async {
    await _service.deleteFile(path: path);
    await loadTree();
  }

  Future<void> duplicateFile(String path) async {
    await _service.duplicateFile(path: path);
    await loadTree();
  }
}

final fileTreeNotifierProvider =
    StateNotifierProvider<FileTreeNotifier, AsyncValue<List<FileNode>>>((ref) {
  final service = ref.watch(fileServiceProvider);
  return FileTreeNotifier(service);
});

// Open File Tabs State Notifier
class OpenTabsState {
  final List<OpenFileTab> tabs;
  final int activeIndex;

  const OpenTabsState({
    required this.tabs,
    this.activeIndex = 0,
  });

  OpenFileTab? get activeTab =>
      (tabs.isNotEmpty && activeIndex >= 0 && activeIndex < tabs.length)
          ? tabs[activeIndex]
          : null;

  OpenTabsState copyWith({
    List<OpenFileTab>? tabs,
    int? activeIndex,
  }) {
    return OpenTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

class OpenTabsNotifier extends StateNotifier<OpenTabsState> {
  final FileService _fileService;

  OpenTabsNotifier(this._fileService)
      : super(const OpenTabsState(tabs: [])) {
    _initDefaultTabs();
  }

  Future<void> _initDefaultTabs() async {
    final appTsx = await _fileService.readFile('src/App.tsx');
    final headerTsx = await _fileService.readFile('src/components/Header.tsx');
    state = OpenTabsState(
      tabs: [
        OpenFileTab(path: 'src/App.tsx', name: 'App.tsx', content: appTsx, isDirty: true),
        OpenFileTab(path: 'src/components/Header.tsx', name: 'Header.tsx', content: headerTsx),
      ],
      activeIndex: 0,
    );
  }

  Future<void> openFile(String path, String name) async {
    final existingIndex = state.tabs.indexWhere((t) => t.path == path);
    if (existingIndex != -1) {
      state = state.copyWith(activeIndex: existingIndex);
      return;
    }
    final content = await _fileService.readFile(path);
    final newTabs = List<OpenFileTab>.from(state.tabs)
      ..add(OpenFileTab(path: path, name: name, content: content));
    state = OpenTabsState(tabs: newTabs, activeIndex: newTabs.length - 1);
  }

  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    final newTabs = List<OpenFileTab>.from(state.tabs)..removeAt(index);
    int newActive = state.activeIndex;
    if (newActive >= newTabs.length) {
      newActive = newTabs.length - 1;
    }
    state = OpenTabsState(tabs: newTabs, activeIndex: newActive >= 0 ? newActive : 0);
  }

  void setActiveTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      state = state.copyWith(activeIndex: index);
    }
  }

  void updateActiveContent(String newContent) {
    if (state.activeTab == null) return;
    final index = state.activeIndex;
    final updatedTab = state.tabs[index].copyWith(
      content: newContent,
      isDirty: true,
    );
    final newTabs = List<OpenFileTab>.from(state.tabs);
    newTabs[index] = updatedTab;
    state = state.copyWith(tabs: newTabs);
  }

  Future<void> saveActiveTab() async {
    final active = state.activeTab;
    if (active == null) return;
    await _fileService.saveFile(active.path, active.content);
    final index = state.activeIndex;
    final updatedTab = active.copyWith(isDirty: false);
    final newTabs = List<OpenFileTab>.from(state.tabs);
    newTabs[index] = updatedTab;
    state = state.copyWith(tabs: newTabs);
  }
}

final openTabsProvider =
    StateNotifierProvider<OpenTabsNotifier, OpenTabsState>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return OpenTabsNotifier(fileService);
});
