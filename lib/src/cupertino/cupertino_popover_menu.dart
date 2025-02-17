import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:overlord/overlord.dart';
import 'package:overlord/src/menus/menu_with_pointer.dart';

/// An iOS-style popover menu.
///
/// A [CupertinoPopoverMenu] displays content within a rounded rectangle shape,
/// along with an arrow that points in the general direction of the [focalPoint].
class CupertinoPopoverMenu extends SingleChildRenderObjectWidget {
  const CupertinoPopoverMenu({
    super.key,
    required this.focalPoint,
    this.borderRadius = 12.0,
    this.arrowBaseWidth = 18.0,
    this.arrowLength = 12.0,
    this.allowHorizontalArrow = true,
    this.backgroundColor = const Color(0xFF474747),
    this.padding,
    this.showDebugPaint = false,
    this.elevation = 0.0,
    this.shadowColor = const Color(0xFF000000),
    super.child,
  }) : assert(elevation >= 0.0);

  /// Where the toolbar arrow should point.
  final MenuFocalPoint focalPoint;

  /// Indicates whether or not the arrow can point to a horizontal direction.
  ///
  /// When `false`, the arrow only points up or down.
  final bool allowHorizontalArrow;

  /// Base of the arrow in pixels.
  ///
  /// If the arrow points up or down, [arrowBaseWidth] represents the number of
  /// pixels in the x-axis. Otherwise, it represents the number of pixels
  /// in the y-axis.
  final double arrowBaseWidth;

  /// Extent of the arrow in pixels.
  ///
  /// If the arrow points up or down, [arrowLength] represents the number of
  /// pixels in the y-axis. Otherwise, it represents the number of pixels
  /// in the x-axis.
  final double arrowLength;

  /// Radius of the corners of the menu content area.
  final double borderRadius;

  /// Padding around the popover content.
  final EdgeInsets? padding;

  /// Color of the menu background.
  final Color backgroundColor;

  /// The virtual distance between this menu and the content that sits beneath it, which determines
  /// the size, opacity, and spread of the menu's shadow.
  ///
  /// The value must be non-negative.
  final double elevation;

  /// The color of the shadow cast by this menu.
  ///
  /// The opacity of [shadowColor] is ignored. Instead, the final opacity of the shadow
  /// is determined by [elevation].
  final Color shadowColor;

  /// Whether to add decorations that show useful metrics for this popover's
  /// layout and position.
  final bool showDebugPaint;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPopover(
      borderRadius: borderRadius,
      arrowWidth: arrowBaseWidth,
      arrowLength: arrowLength,
      padding: padding,
      screenSize: MediaQuery.of(context).size,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      focalPoint: focalPoint,
      allowHorizontalArrow: allowHorizontalArrow,
      showDebugPaint: showDebugPaint,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderPopover renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..borderRadius = borderRadius
      ..arrowBaseWidth = arrowBaseWidth
      ..arrowLength = arrowLength
      ..padding = padding
      ..screenSize = MediaQuery.of(context).size
      ..focalPoint = focalPoint
      ..backgroundColor = backgroundColor
      ..elevation = elevation
      ..shadowColor = shadowColor
      ..allowHorizontalArrow = allowHorizontalArrow
      ..showDebugPaint = showDebugPaint;
  }
}

class RenderPopover extends RenderShiftedBox {
  RenderPopover({
    required double borderRadius,
    required double arrowWidth,
    required double arrowLength,
    required Color backgroundColor,
    required double elevation,
    required Color shadowColor,
    required MenuFocalPoint focalPoint,
    required Size screenSize,
    bool allowHorizontalArrow = true,
    EdgeInsets? padding,
    bool showDebugPaint = false,
    RenderBox? child,
  })  : _borderRadius = borderRadius,
        _arrowBaseWidth = arrowWidth,
        _arrowLength = arrowLength,
        _padding = padding,
        _screenSize = screenSize,
        _backgroundColor = backgroundColor,
        _elevation = elevation,
        _shadowColor = shadowColor,
        _backgroundPaint = Paint()..color = backgroundColor,
        _focalPoint = focalPoint,
        _allowHorizontalArrow = allowHorizontalArrow,
        _showDebugPaint = showDebugPaint,
        super(child);

  double _borderRadius;
  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsLayout();
    }
  }

  double _arrowBaseWidth;
  double get arrowBaseWidth => _arrowBaseWidth;
  set arrowBaseWidth(double value) {
    if (_arrowBaseWidth != value) {
      _arrowBaseWidth = value;
      markNeedsLayout();
    }
  }

  double _arrowLength;
  double get arrowLength => _arrowLength;
  set arrowLength(double value) {
    if (_arrowLength != value) {
      _arrowLength = value;
      markNeedsLayout();
    }
  }

  MenuFocalPoint _focalPoint;
  MenuFocalPoint get focalPoint => _focalPoint;
  set focalPoint(MenuFocalPoint value) {
    if (_focalPoint != value) {
      _focalPoint = value;
      markNeedsLayout();
    }
  }

  EdgeInsets? _padding;
  EdgeInsets? get padding => _padding;
  set padding(EdgeInsets? value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  Size _screenSize;
  Size get screenSize => _screenSize;
  set screenSize(Size value) {
    if (value != _screenSize) {
      _screenSize = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (value != _backgroundColor) {
      _backgroundColor = value;
      _backgroundPaint = Paint()..color = _backgroundColor;
      markNeedsPaint();
    }
  }

  double _elevation;
  double get elevation => _elevation;
  set elevation(double value) {
    if (value != _elevation) {
      _elevation = value;
      markNeedsPaint();
    }
  }

  Color _shadowColor;
  Color get shadowColor => _shadowColor;
  set shadowColor(Color value) {
    if (value != _shadowColor) {
      _shadowColor = value;
      markNeedsPaint();
    }
  }

  bool get allowHorizontalArrow => _allowHorizontalArrow;
  bool _allowHorizontalArrow;
  set allowHorizontalArrow(bool value) {
    if (value != _allowHorizontalArrow) {
      _allowHorizontalArrow = value;
      markNeedsLayout();
    }
  }

  set showDebugPaint(bool newValue) {
    if (newValue == _showDebugPaint) {
      return;
    }

    _showDebugPaint = newValue;
    markNeedsPaint();
  }

  Offset _contentOffset = Offset.zero;

  bool _showDebugPaint = false;

  late Paint _backgroundPaint;

  @override
  void performLayout() {
    final reservedSize = Size(
      (padding?.horizontal ?? 0) + (arrowLength * 2),
      (padding?.vertical ?? 0) + (arrowLength * 2),
    );

    // Compute the child constraints to leave space for the arrow and padding.
    final innerConstraints = constraints.enforce(
      BoxConstraints(
        maxHeight: min(_screenSize.height, constraints.maxHeight) - reservedSize.height,
        maxWidth: min(_screenSize.width, constraints.maxWidth) - reservedSize.width,
      ),
    );

    _contentOffset = _computeContentOffset(arrowLength);

    child!.layout(innerConstraints, parentUsesSize: true);

    size = constraints.constrain(Size(
      reservedSize.width + child!.size.width,
      reservedSize.height + child!.size.height,
    ));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    late ArrowDirection direction;
    late double arrowCenter;

    final localFocalPoint = focalPoint.globalOffset != null ? globalToLocal(focalPoint.globalOffset!) : null;
    if (localFocalPoint != null) {
      // We have a menu focal point. Orient the arrow towards that
      // focal point.
      direction = _computeArrowDirection(Offset.zero & size, localFocalPoint);
      arrowCenter = _computeArrowCenter(direction, localFocalPoint);
    } else {
      // We don't have a menu focal point. Perhaps this is a moment just
      // before, or just after a focal point becomes available. Until then,
      // render with the arrow pointing down from the center of the toolbar,
      // as an arbitrary arrow position.
      direction = ArrowDirection.down;
      arrowCenter = 0.5;
    }

    final borderPath = _buildBorderPath(direction, arrowCenter);

    if (elevation != 0.0) {
      final isMenuTranslucent = _backgroundColor.alpha != 0xFF;
      context.canvas.drawShadow(
        borderPath,
        _shadowColor,
        _elevation,
        isMenuTranslucent,
      );
    }

    context.canvas.drawPath(borderPath.shift(offset), _backgroundPaint);

    if (child != null) {
      context.paintChild(child!, offset + _contentOffset);
    }

    if (_showDebugPaint) {
      context.canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );

      if (localFocalPoint != null) {
        context.canvas.drawCircle(localFocalPoint, 10, Paint()..color = Colors.blue);
      }
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    // Applying our padding offset to the paint transform lets Flutter's
    // "Debug Paint" show the correct child widget bounds.
    return transform.translate(_contentOffset.dx, _contentOffset.dy);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position)) {
      return true;
    }
    // Allow hit-testing around the content, e.g, we might have padding and
    // the user is trying to drag using the padding area.
    final rect = Offset.zero & size;
    return rect.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _contentOffset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - _contentOffset);
        return child?.hitTest(result, position: transformed) ?? false;
      },
    );
  }

  /// Builds the path used to paint the menu.
  ///
  /// The path includes a rounded rectangle and a arrow pointing to [arrowDirection], centered at [arrowCenter].
  Path _buildBorderPath(ArrowDirection arrowDirection, double arrowCenter) {
    final halfOfBase = arrowBaseWidth / 2;

    // Adjust the rect to leave space for the arrow.
    // During layout, we reserve space for the arrow in both x and y axis.
    final contentRect = Rect.fromLTWH(
      arrowLength,
      arrowLength,
      size.width - arrowLength * 2,
      size.height - arrowLength * 2,
    );

    Path path = Path()..addRRect(RRect.fromRectAndRadius(contentRect, Radius.circular(borderRadius)));

    // Add the arrow.
    if (arrowDirection == ArrowDirection.left) {
      path
        ..moveTo(contentRect.centerLeft.dx, arrowCenter - halfOfBase)
        ..relativeLineTo(-arrowLength, halfOfBase)
        ..relativeLineTo(arrowLength, halfOfBase);
    } else if (arrowDirection == ArrowDirection.right) {
      path
        ..moveTo(contentRect.centerRight.dx, arrowCenter - halfOfBase)
        ..relativeLineTo(arrowLength, halfOfBase)
        ..relativeLineTo(-arrowLength, halfOfBase);
    } else if (arrowDirection == ArrowDirection.up) {
      path
        ..moveTo(arrowCenter - halfOfBase, contentRect.topCenter.dy)
        ..relativeLineTo(halfOfBase, -arrowLength)
        ..relativeLineTo(halfOfBase, arrowLength);
    } else {
      path
        ..moveTo(arrowCenter - halfOfBase, contentRect.bottomCenter.dy)
        ..relativeLineTo(halfOfBase, arrowLength)
        ..relativeLineTo(halfOfBase, -arrowLength);
    }

    path.close();

    return path;
  }

  /// Computes the direction where the arrow should point to.
  ///
  /// If [globalFocalPoint] is inside the [menuRect] horizontal bounds, the arrow points up or right. Otherwise,
  /// the arrow points left or right.
  ///
  /// If [allowHorizontalArrow] is `false`, the arrow only points up or down.
  ArrowDirection _computeArrowDirection(Rect menuRect, Offset globalFocalPoint) {
    final isFocalPointInsideHorizontalBounds =
        globalFocalPoint.dx >= menuRect.left && globalFocalPoint.dx <= menuRect.right;

    if (isFocalPointInsideHorizontalBounds || !allowHorizontalArrow) {
      if (globalFocalPoint.dy < menuRect.top) {
        return ArrowDirection.up;
      }
      return ArrowDirection.down;
    } else {
      if (globalFocalPoint.dx < menuRect.left) {
        return ArrowDirection.left;
      }
      return ArrowDirection.right;
    }
  }

  /// Computes the center point of the arrow.
  ///
  /// This point can be on the x or y axis, depending on the [direction].
  double _computeArrowCenter(ArrowDirection direction, Offset focalPoint) {
    final desiredFocalPoint = _isArrowVertical(direction) //
        ? focalPoint.dx
        : focalPoint.dy;

    return _constrainFocalPoint(desiredFocalPoint, direction);
  }

  /// Computes the (x, y) offset used to paint the menu content inside the popover.
  Offset _computeContentOffset(double arrowLength) {
    return Offset(
      (padding?.left ?? 0) + arrowLength,
      (padding?.top ?? 0) + arrowLength,
    );
  }

  /// Indicates whether or not the arrow points to a vertical direction.
  bool _isArrowVertical(ArrowDirection arrowDirection) =>
      arrowDirection == ArrowDirection.up || arrowDirection == ArrowDirection.down;

  /// Minimum focal point for the given [arrowDirection] in which the arrow can be displayed inside the popover bounds.
  double _minArrowFocalPoint(ArrowDirection arrowDirection) => _isArrowVertical(arrowDirection)
      ? _minArrowHorizontalCenter(arrowDirection)
      : _minArrowVerticalCenter(arrowDirection);

  /// Maximum focal point for the given [arrowDirection] in which the arrow can be displayed inside the popover bounds.
  double _maxArrowFocalPoint(ArrowDirection arrowDirection) => _isArrowVertical(arrowDirection)
      ? _maxArrowHorizontalCenter(arrowDirection)
      : _maxArrowVerticalCenter(arrowDirection);

  /// Minimum distance on the x-axis in which the arrow can be displayed without being above the corner.
  double _minArrowHorizontalCenter(ArrowDirection arrowDirection) => (borderRadius + arrowBaseWidth / 2) + arrowLength;

  /// Maximum distance on the x-axis in which the arrow can be displayed without being above the corner.
  double _maxArrowHorizontalCenter(ArrowDirection arrowDirection) =>
      (size.width - borderRadius - arrowBaseWidth - arrowLength / 2);

  /// Minimum distance on the y-axis which the arrow can be displayed without being above the corner.
  double _minArrowVerticalCenter(ArrowDirection arrowDirection) => (borderRadius + arrowBaseWidth / 2) + arrowLength;

  /// Maximum distance on the y-axis which the arrow can be displayed without being above the corner.
  double _maxArrowVerticalCenter(ArrowDirection arrowDirection) =>
      (size.height - borderRadius - arrowLength - (arrowBaseWidth / 2));

  /// Constrain the focal point to be inside the menu bounds, respecting the minimum and maximum focal points.
  double _constrainFocalPoint(double desiredFocalPoint, ArrowDirection arrowDirection) {
    return min(max(desiredFocalPoint, _minArrowFocalPoint(arrowDirection)), _maxArrowFocalPoint(arrowDirection));
  }
}

/// Direction where a arrow points to.
enum ArrowDirection {
  up,
  down,
  left,
  right,
}
