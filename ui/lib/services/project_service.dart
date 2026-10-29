import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';

abstract class ProjectService {
  Future<List<Project>> getProjects();
  Future<Project> createProject({
    required String name,
    required String template,
  });
  Future<Project> cloneRepository({required String repoUrl});
  Future<Project> wakeProject(String projectId);
  Future<Project> stopProject(String projectId);
}

class MockProjectService implements ProjectService {
  final List<Project> _projects = [
    Project(
      id: 'proj_react_vite',
      name: 'react-shop-mobile',
      description: 'Mobile e-commerce web app built with React 19 + Vite & Tailwind',
      stack: 'react_vite',
      stackLabel: 'React + Vite',
      stackIcon: 'react',
      lastOpened: DateTime.now().subtract(const Duration(minutes: 5)),
      status: ProjectStatus.running,
      containerUrl: 'http://localhost:5173',
      port: 5173,
    ),
    Project(
      id: 'proj_nextjs',
      name: 'saas-dashboard-next',
      description: 'Fullstack Next.js 15 App router dashboard with Server Actions',
      stack: 'nextjs',
      stackLabel: 'Next.js',
      stackIcon: 'next',
      lastOpened: DateTime.now().subtract(const Duration(hours: 3)),
      status: ProjectStatus.sleeping,
      containerUrl: 'http://localhost:3000',
      port: 3000,
    ),
    Project(
      id: 'proj_python_api',
      name: 'ai-summary-agent',
      description: 'FastAPI Python backend with LangChain streaming endpoints',
      stack: 'python',
      stackLabel: 'Python FastAPI',
      stackIcon: 'python',
      lastOpened: DateTime.now().subtract(const Duration(days: 1)),
      status: ProjectStatus.starting,
      containerUrl: 'http://localhost:8000',
      port: 8000,
    ),
    Project(
      id: 'proj_flutter_web',
      name: 'crypto-tracker-flutter',
      description: 'Cross-platform financial charts with Flutter CanvasKit web',
      stack: 'flutter',
      stackLabel: 'Flutter Web',
      stackIcon: 'flutter',
      lastOpened: DateTime.now().subtract(const Duration(days: 4)),
      status: ProjectStatus.sleeping,
      containerUrl: 'http://localhost:8080',
      port: 8080,
    ),
  ];

  @override
  Future<List<Project>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_projects);
  }

  @override
  Future<Project> createProject({
    required String name,
    required String template,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    String stackLabel = 'Workspace';
    String icon = 'terminal';
    int port = 5173;

    final newProj = Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().replaceAll(' ', '-').toLowerCase(),
      description: 'Workspace ready for terminal environment setup',
      stack: 'workspace',
      stackLabel: stackLabel,
      stackIcon: icon,
      lastOpened: DateTime.now(),
      status: ProjectStatus.starting,
      containerUrl: 'http://localhost:$port',
      port: port,
    );

    _projects.insert(0, newProj);
    return newProj;
  }

  @override
  Future<Project> cloneRepository({required String repoUrl}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final repoName = repoUrl.split('/').last.replaceAll('.git', '');
    final newProj = Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: repoName.isNotEmpty ? repoName : 'cloned-repo',
      description: 'Cloned from $repoUrl',
      stack: 'react_vite',
      stackLabel: 'React + Vite',
      stackIcon: 'react',
      lastOpened: DateTime.now(),
      status: ProjectStatus.starting,
      containerUrl: 'http://localhost:5173',
      port: 5173,
    );
    _projects.insert(0, newProj);
    return newProj;
  }

  @override
  Future<Project> wakeProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updated = _projects[index].copyWith(
        status: ProjectStatus.running,
        lastOpened: DateTime.now(),
      );
      _projects[index] = updated;
      return updated;
    }
    throw Exception('Project not found');
  }

  @override
  Future<Project> stopProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updated = _projects[index].copyWith(
        status: ProjectStatus.sleeping,
      );
      _projects[index] = updated;
      return updated;
    }
    throw Exception('Project not found');
  }
}

// Providers
final projectServiceProvider = Provider<ProjectService>((ref) {
  return MockProjectService();
});

class ProjectsNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectService _service;

  ProjectsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final items = await _service.getProjects();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Project?> createProject(String name, String template) async {
    try {
      final proj = await _service.createProject(name: name, template: template);
      await loadProjects();
      return proj;
    } catch (_) {
      return null;
    }
  }

  Future<Project?> cloneRepo(String url) async {
    try {
      final proj = await _service.cloneRepository(repoUrl: url);
      await loadProjects();
      return proj;
    } catch (_) {
      return null;
    }
  }

  Future<void> wakeProject(String id) async {
    await _service.wakeProject(id);
    await loadProjects();
  }
}

final projectsNotifierProvider =
    StateNotifierProvider<ProjectsNotifier, AsyncValue<List<Project>>>((ref) {
  final service = ref.watch(projectServiceProvider);
  return ProjectsNotifier(service);
});

final currentProjectProvider = StateProvider<Project?>((ref) {
  final projectsState = ref.watch(projectsNotifierProvider);
  return projectsState.when(
    data: (list) => list.isNotEmpty ? list.first : null,
    loading: () => null,
    error: (_, _) => null,
  );
});
