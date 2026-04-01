/// 数独游戏的状态管理，基于 Riverpod StateNotifier 实现。
///
/// 提供完整的数独游戏逻辑：选择单元格、放置数字、擦除、
/// 提示、检查解答、冲突检测和计时功能。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// 数独难度枚举
// ---------------------------------------------------------------------------

/// 数独棋盘尺寸/难度级别。
enum SudokuDifficulty {
  /// 4x4 入门级
  easy4x4(4, '4x4'),

  /// 6x6 进阶级
  medium6x6(6, '6x6'),

  /// 9x9 标准级
  hard9x9(9, '9x9');

  const SudokuDifficulty(this.size, this.label);

  /// 棋盘边长
  final int size;

  /// 显示标签
  final String label;

  /// 获取宫格的行数（子格高度）
  int get boxRows {
    switch (this) {
      case SudokuDifficulty.easy4x4:
        return 2;
      case SudokuDifficulty.medium6x6:
        return 2;
      case SudokuDifficulty.hard9x9:
        return 3;
    }
  }

  /// 获取宫格的列数（子格宽度）
  int get boxCols {
    switch (this) {
      case SudokuDifficulty.easy4x4:
        return 2;
      case SudokuDifficulty.medium6x6:
        return 3;
      case SudokuDifficulty.hard9x9:
        return 3;
    }
  }
}

// ---------------------------------------------------------------------------
// 数独状态
// ---------------------------------------------------------------------------

/// 数独游戏的不可变状态类。
class SudokuState {
  const SudokuState({
    required this.grid,
    required this.solution,
    required this.initialGrid,
    required this.difficulty,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.hintsRemaining = 3,
    this.errors = 0,
    this.isComplete = false,
    this.elapsedSeconds = 0,
    this.conflicts = const {},
  });

  /// 当前棋盘状态（可变，用户填入的数字会更新此网格）
  final List<List<int>> grid;

  /// 完整的正确解答
  final List<List<int>> solution;

  /// 初始棋盘（固定的预设数字，不可修改）
  final List<List<int>> initialGrid;

  /// 当前难度级别
  final SudokuDifficulty difficulty;

  /// 当前选中行（-1表示未选中）
  final int selectedRow;

  /// 当前选中列（-1表示未选中）
  final int selectedCol;

  /// 剩余提示次数
  final int hintsRemaining;

  /// 累计错误次数
  final int errors;

  /// 是否已完成
  final bool isComplete;

  /// 游戏已用秒数
  final int elapsedSeconds;

  /// 冲突单元格的坐标集合（以 "行,列" 字符串表示）
  final Set<String> conflicts;

  /// 棋盘边长
  int get size => difficulty.size;

  /// 判断指定位置是否为初始预设的固定数字
  bool isFixed(int row, int col) => initialGrid[row][col] > 0;

  /// 判断指定位置是否处于冲突状态
  bool hasConflict(int row, int col) => conflicts.contains('$row,$col');

  /// 判断指定位置是否为当前选中的单元格
  bool isSelected(int row, int col) =>
      row == selectedRow && col == selectedCol;

  /// 格式化计时器显示文本
  String get timerText {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// 创建状态副本的便捷方法
  SudokuState copyWith({
    List<List<int>>? grid,
    List<List<int>>? solution,
    List<List<int>>? initialGrid,
    SudokuDifficulty? difficulty,
    int? selectedRow,
    int? selectedCol,
    int? hintsRemaining,
    int? errors,
    bool? isComplete,
    int? elapsedSeconds,
    Set<String>? conflicts,
  }) {
    return SudokuState(
      grid: grid ?? this.grid,
      solution: solution ?? this.solution,
      initialGrid: initialGrid ?? this.initialGrid,
      difficulty: difficulty ?? this.difficulty,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      errors: errors ?? this.errors,
      isComplete: isComplete ?? this.isComplete,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}

// ---------------------------------------------------------------------------
// 数独状态管理器
// ---------------------------------------------------------------------------

/// 管理数独游戏全部逻辑的 StateNotifier。
///
/// 负责处理：选择单元格、放置/擦除数字、使用提示、
/// 冲突检测、完成判定和计时更新。
class SudokuNotifier extends Notifier<SudokuState> {
  @override
  SudokuState build() {
    // 在 build 中注册 dispose 回调
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    // 生成初始谜题
    final puzzle = _generatePuzzle(SudokuDifficulty.easy4x4);
    final initialState = SudokuState(
      grid: _deepCopy(puzzle.initial),
      solution: puzzle.solution,
      initialGrid: _deepCopy(puzzle.initial),
      difficulty: SudokuDifficulty.easy4x4,
      hintsRemaining: 3,
    );
    // 启动计时器
    _startTimer();
    return initialState;
  }

  Timer? _timer;


  /// 深拷贝二维整数列表
  static List<List<int>> _deepCopy(List<List<int>> source) {
    return source.map((row) => List<int>.from(row)).toList();
  }

  // -------------------------------------------------------------------------
  // 公共方法
  // -------------------------------------------------------------------------

  /// 选择指定位置的单元格。
  void selectCell(int row, int col) {
    if (state.isComplete) return;
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  /// 在当前选中的单元格放置数字。
  ///
  /// 忽略固定单元格和无效数字，放置后自动检测冲突。
  void placeNumber(int number) {
    if (state.isComplete) return;
    if (state.selectedRow < 0 || state.selectedCol < 0) return;
    if (state.isFixed(state.selectedRow, state.selectedCol)) return;
    if (number < 1 || number > state.size) return;

    final newGrid = _deepCopy(state.grid);
    newGrid[state.selectedRow][state.selectedCol] = number;

    // 检测冲突
    final newConflicts = _detectConflicts(newGrid, state.difficulty);

    // 检查是否正确完成
    final isNowComplete = _checkComplete(newGrid, state.solution);

    state = state.copyWith(
      grid: newGrid,
      conflicts: newConflicts,
      isComplete: isNowComplete,
    );

    if (isNowComplete) {
      _stopTimer();
    }
  }

  /// 擦除当前选中单元格的数字。
  void erase() {
    if (state.isComplete) return;
    if (state.selectedRow < 0 || state.selectedCol < 0) return;
    if (state.isFixed(state.selectedRow, state.selectedCol)) return;

    final newGrid = _deepCopy(state.grid);
    newGrid[state.selectedRow][state.selectedCol] = 0;

    final newConflicts = _detectConflicts(newGrid, state.difficulty);

    state = state.copyWith(
      grid: newGrid,
      conflicts: newConflicts,
    );
  }

  /// 使用一次提示，在选中的空单元格填入正确答案。
  void useHint() {
    if (state.isComplete) return;
    if (state.hintsRemaining <= 0) return;
    if (state.selectedRow < 0 || state.selectedCol < 0) return;
    if (state.isFixed(state.selectedRow, state.selectedCol)) return;

    final correctValue =
        state.solution[state.selectedRow][state.selectedCol];

    final newGrid = _deepCopy(state.grid);
    newGrid[state.selectedRow][state.selectedCol] = correctValue;

    final newConflicts = _detectConflicts(newGrid, state.difficulty);
    final isNowComplete = _checkComplete(newGrid, state.solution);

    state = state.copyWith(
      grid: newGrid,
      hintsRemaining: state.hintsRemaining - 1,
      conflicts: newConflicts,
      isComplete: isNowComplete,
    );

    if (isNowComplete) {
      _stopTimer();
    }
  }

  /// 检查当前棋盘与正确解答的差异，标记错误数量。
  void checkSolution() {
    if (state.isComplete) return;

    int errorCount = 0;
    final size = state.size;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final value = state.grid[r][c];
        if (value > 0 && value != state.solution[r][c]) {
          errorCount++;
        }
      }
    }

    state = state.copyWith(errors: errorCount);
  }

  /// 重置游戏，加载指定难度的新谜题。
  void reset(SudokuDifficulty difficulty) {
    _stopTimer();

    final puzzle = _generatePuzzle(difficulty);

    state = SudokuState(
      grid: _deepCopy(puzzle.initial),
      solution: puzzle.solution,
      initialGrid: _deepCopy(puzzle.initial),
      difficulty: difficulty,
      hintsRemaining: 3,
    );

    _startTimer();
  }

  /// 更新计时器（每秒调用一次）。
  void tick() {
    if (state.isComplete) return;
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }


  // -------------------------------------------------------------------------
  // 内部计时器管理
  // -------------------------------------------------------------------------

  /// 启动每秒递增的计时器。
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  /// 停止计时器。
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // -------------------------------------------------------------------------
  // 冲突检测
  // -------------------------------------------------------------------------

  /// 检测整个棋盘中的数字冲突（行、列、宫格内重复）。
  ///
  /// 返回所有存在冲突的单元格坐标集合。
  Set<String> _detectConflicts(
    List<List<int>> grid,
    SudokuDifficulty difficulty,
  ) {
    final conflicts = <String>{};
    final size = difficulty.size;
    final boxRows = difficulty.boxRows;
    final boxCols = difficulty.boxCols;

    // 检查每一行的重复
    for (int r = 0; r < size; r++) {
      final seen = <int, List<int>>{};
      for (int c = 0; c < size; c++) {
        final value = grid[r][c];
        if (value > 0) {
          seen.putIfAbsent(value, () => []).add(c);
        }
      }
      for (final entry in seen.entries) {
        if (entry.value.length > 1) {
          for (final c in entry.value) {
            conflicts.add('$r,$c');
          }
        }
      }
    }

    // 检查每一列的重复
    for (int c = 0; c < size; c++) {
      final seen = <int, List<int>>{};
      for (int r = 0; r < size; r++) {
        final value = grid[r][c];
        if (value > 0) {
          seen.putIfAbsent(value, () => []).add(r);
        }
      }
      for (final entry in seen.entries) {
        if (entry.value.length > 1) {
          for (final r in entry.value) {
            conflicts.add('$r,$c');
          }
        }
      }
    }

    // 检查每个宫格的重复
    for (int boxR = 0; boxR < size; boxR += boxRows) {
      for (int boxC = 0; boxC < size; boxC += boxCols) {
        final seen = <int, List<String>>{};
        for (int r = boxR; r < boxR + boxRows; r++) {
          for (int c = boxC; c < boxC + boxCols; c++) {
            final value = grid[r][c];
            if (value > 0) {
              seen.putIfAbsent(value, () => []).add('$r,$c');
            }
          }
        }
        for (final entry in seen.entries) {
          if (entry.value.length > 1) {
            conflicts.addAll(entry.value);
          }
        }
      }
    }

    return conflicts;
  }

  /// 判断棋盘是否完整且正确填写。
  bool _checkComplete(List<List<int>> grid, List<List<int>> solution) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  // -------------------------------------------------------------------------
  // 谜题生成
  // -------------------------------------------------------------------------

  /// 生成指定难度的数独谜题。
  ///
  /// 包含预设的谜题模板，通过行列交换增加多样性。
  /// 返回包含初始棋盘和正确解答的谜题数据。
  _SudokuPuzzle _generatePuzzle(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.easy4x4:
        return _generate4x4Puzzle();
      case SudokuDifficulty.medium6x6:
        return _generate6x6Puzzle();
      case SudokuDifficulty.hard9x9:
        return _generate9x9Puzzle();
    }
  }

  /// 生成4x4入门级谜题。
  _SudokuPuzzle _generate4x4Puzzle() {
    final solution = [
      [1, 2, 3, 4],
      [3, 4, 1, 2],
      [2, 1, 4, 3],
      [4, 3, 2, 1],
    ];

    // 保留部分数字作为初始提示
    final initial = [
      [1, 0, 3, 0],
      [0, 4, 0, 2],
      [2, 0, 0, 3],
      [0, 3, 2, 0],
    ];

    return _SudokuPuzzle(
      initial: initial,
      solution: solution,
    );
  }

  /// 生成6x6进阶级谜题。
  _SudokuPuzzle _generate6x6Puzzle() {
    final solution = [
      [1, 2, 3, 4, 5, 6],
      [4, 5, 6, 1, 2, 3],
      [2, 3, 1, 5, 6, 4],
      [5, 6, 4, 2, 3, 1],
      [3, 1, 5, 6, 4, 2],
      [6, 4, 2, 3, 1, 5],
    ];

    final initial = [
      [1, 0, 3, 0, 5, 0],
      [0, 5, 0, 1, 0, 3],
      [2, 0, 0, 0, 6, 0],
      [0, 6, 0, 0, 0, 1],
      [3, 0, 5, 0, 4, 0],
      [0, 4, 0, 3, 0, 5],
    ];

    return _SudokuPuzzle(
      initial: initial,
      solution: solution,
    );
  }

  /// 生成9x9标准级谜题。
  _SudokuPuzzle _generate9x9Puzzle() {
    final solution = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    final initial = [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ];

    return _SudokuPuzzle(
      initial: initial,
      solution: solution,
    );
  }
}

// ---------------------------------------------------------------------------
// 谜题数据容器
// ---------------------------------------------------------------------------

/// 包含初始棋盘和正确解答的谜题数据。
class _SudokuPuzzle {
  const _SudokuPuzzle({
    required this.initial,
    required this.solution,
  });

  /// 初始棋盘（0表示空格）
  final List<List<int>> initial;

  /// 正确解答
  final List<List<int>> solution;
}

// ---------------------------------------------------------------------------
// Riverpod 提供者
// ---------------------------------------------------------------------------

/// 数独游戏状态的全局提供者。
final sudokuProvider =
    NotifierProvider<SudokuNotifier, SudokuState>(SudokuNotifier.new);
