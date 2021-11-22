package com.beike.flutterweb.web

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.graphics.Rect
import android.os.Build
import android.util.AttributeSet
import android.util.DisplayMetrics
import android.view.Surface
import android.view.WindowInsets
import android.view.WindowManager
import android.webkit.WebView
import androidx.annotation.RequiresApi

/**
 * Created by beike on 2021/10/18
 */
class FWWebView : WebView {
    val metrics = ViewportMetrics()

    constructor(context: Context) : super(context) {
        setMetricsDensity(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        setMetricsDensity(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        setMetricsDensity(context)
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    constructor(
        context: Context,
        attrs: AttributeSet?,
        defStyleAttr: Int,
        defStyleRes: Int
    ) : super(context, attrs, defStyleAttr, defStyleRes) {
        setMetricsDensity(context)
    }

    constructor(
        context: Context, attrs: AttributeSet?, defStyleAttr: Int,
        privateBrowsing: Boolean
    ) : super(context, attrs, defStyleAttr, privateBrowsing) {
        setMetricsDensity(context)
    }

    private fun setMetricsDensity(context: Context) {
        var dm = DisplayMetrics()
        if (context is Activity) {
            // 实际使用这个,因为下面那个API（FlutterView是使用的下面那个）有时候会取值不同,这个后面再研究下
            context.windowManager.defaultDisplay.getMetrics(dm)
        } else {
            dm = resources.displayMetrics
        }
        metrics.devicePixelRatio = dm.density
    }

    class ViewportMetrics {
        var devicePixelRatio = 1.0f
        var physicalWidth = 0
        var physicalHeight = 0
        var physicalPaddingTop = 0
        var physicalPaddingRight = 0
        var physicalPaddingBottom = 0
        var physicalPaddingLeft = 0
        var physicalViewInsetTop = 0
        var physicalViewInsetRight = 0
        var physicalViewInsetBottom = 0
        var physicalViewInsetLeft = 0
        var systemGestureInsetTop = 0
        var systemGestureInsetRight = 0
        var systemGestureInsetBottom = 0
        var systemGestureInsetLeft = 0
    }

    private enum class ZeroSides {
        NONE, LEFT, RIGHT, BOTH
    }

    // Logic Copy From FlutterView
    // This callback is not present in API < 20, which means lower API devices will see
    // the wider than expected padding when the status and navigation bars are hidden.
    // The annotations to suppress "InlinedApi" and "NewApi" lints prevent lint warnings
    // caused by usage of Android Q APIs. These calls are safe because they are
    // guarded.
    @TargetApi(20)
    @RequiresApi(20)
    @SuppressLint("InlinedApi", "NewApi")
    override fun onApplyWindowInsets(insets: WindowInsets): WindowInsets {
        // getSystemGestureInsets() was introduced in API 29 and immediately deprecated in 30.
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            val systemGestureInsets = insets.systemGestureInsets
            metrics.systemGestureInsetTop = systemGestureInsets.top
            metrics.systemGestureInsetRight = systemGestureInsets.right
            metrics.systemGestureInsetBottom = systemGestureInsets.bottom
            metrics.systemGestureInsetLeft = systemGestureInsets.left
        }
        val statusBarVisible = SYSTEM_UI_FLAG_FULLSCREEN and windowSystemUiVisibility == 0
        val navigationBarVisible = SYSTEM_UI_FLAG_HIDE_NAVIGATION and windowSystemUiVisibility == 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            var mask = 0
            if (navigationBarVisible) {
                mask = mask or WindowInsets.Type.navigationBars()
            }
            if (statusBarVisible) {
                mask = mask or WindowInsets.Type.statusBars()
            }
            val uiInsets = insets.getInsets(mask)
            metrics.physicalPaddingTop = uiInsets.top
            metrics.physicalPaddingRight = uiInsets.right
            metrics.physicalPaddingBottom = uiInsets.bottom
            metrics.physicalPaddingLeft = uiInsets.left
            val imeInsets = insets.getInsets(WindowInsets.Type.ime())
            metrics.physicalViewInsetTop = imeInsets.top
            metrics.physicalViewInsetRight = imeInsets.right
            metrics.physicalViewInsetBottom = imeInsets.bottom // Typically, only bottom is non-zero
            metrics.physicalViewInsetLeft = imeInsets.left
            val systemGestureInsets = insets.getInsets(WindowInsets.Type.systemGestures())
            metrics.systemGestureInsetTop = systemGestureInsets.top
            metrics.systemGestureInsetRight = systemGestureInsets.right
            metrics.systemGestureInsetBottom = systemGestureInsets.bottom
            metrics.systemGestureInsetLeft = systemGestureInsets.left


            // Take the max of the display cutout insets and existing padding to merge them
            val cutout = insets.displayCutout
            if (cutout != null) {
                val waterfallInsets = cutout.waterfallInsets
                metrics.physicalPaddingTop = Math.max(
                    Math.max(metrics.physicalPaddingTop, waterfallInsets.top),
                    cutout.safeInsetTop
                )
                metrics.physicalPaddingRight = Math.max(
                    Math.max(metrics.physicalPaddingRight, waterfallInsets.right),
                    cutout.safeInsetRight
                )
                metrics.physicalPaddingBottom = Math.max(
                    Math.max(metrics.physicalPaddingBottom, waterfallInsets.bottom),
                    cutout.safeInsetBottom
                )
                metrics.physicalPaddingLeft = Math.max(
                    Math.max(metrics.physicalPaddingLeft, waterfallInsets.left),
                    cutout.safeInsetLeft
                )
            }
        } else {
            // We zero the left and/or right sides to prevent the padding the
            // navigation bar would have caused.
            var zeroSides = ZeroSides.NONE
            if (!navigationBarVisible) {
                zeroSides = calculateShouldZeroSides()
            }

            // Status bar (top) and left/right system insets should partially obscure the content
            // (padding).
            metrics.physicalPaddingTop = if (statusBarVisible) insets.systemWindowInsetTop else 0
            metrics.physicalPaddingRight =
                if (zeroSides == ZeroSides.RIGHT || zeroSides == ZeroSides.BOTH) 0 else insets.systemWindowInsetRight
            metrics.physicalPaddingBottom = 0
            metrics.physicalPaddingLeft =
                if (zeroSides == ZeroSides.LEFT || zeroSides == ZeroSides.BOTH) 0 else insets.systemWindowInsetLeft

            // Bottom system inset (keyboard) should adjust scrollable bottom edge (inset).
            metrics.physicalViewInsetTop = 0
            metrics.physicalViewInsetRight = 0
            metrics.physicalViewInsetBottom =
                if (navigationBarVisible) insets.systemWindowInsetBottom else guessBottomKeyboardInset(
                    insets
                )
            metrics.physicalViewInsetLeft = 0
        }
        return super.onApplyWindowInsets(insets)
    }

    private fun calculateShouldZeroSides(): ZeroSides {
        // We get both orientation and rotation because rotation is all 4
        // rotations relative to default rotation while orientation is portrait
        // or landscape. By combining both, we can obtain a more precise measure
        // of the rotation.
        val context = context
        val orientation = context.resources.configuration.orientation
        val rotation = (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
            .defaultDisplay
            .rotation
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (rotation == Surface.ROTATION_90) {
                return ZeroSides.RIGHT
            } else if (rotation == Surface.ROTATION_270) {
                // In android API >= 23, the nav bar always appears on the "bottom" (USB) side.
                return if (Build.VERSION.SDK_INT >= 23) ZeroSides.LEFT else ZeroSides.RIGHT
            } else if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) {
                return ZeroSides.BOTH
            }
        }
        // Square orientation deprecated in API 16, we will not check for it and return false
        // to be safe and not remove any unique padding for the devices that do use it.
        return ZeroSides.NONE
    }

    @TargetApi(20)
    @RequiresApi(20)
    private fun guessBottomKeyboardInset(insets: WindowInsets): Int {
        val screenHeight = rootView.height
        // Magic number due to this being a heuristic. This should be replaced, but we have not
        // found a clean way to do it yet (Sept. 2018)
        val keyboardHeightRatioHeuristic = 0.18
        return if (insets.systemWindowInsetBottom < screenHeight * keyboardHeightRatioHeuristic) {
            // Is not a keyboard, so return zero as inset.
            0
        } else {
            // Is a keyboard, so return the full inset.
            insets.systemWindowInsetBottom
        }
    }

    // Logic Copy From FlutterView
    override fun fitSystemWindows(insets: Rect): Boolean {
        return if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
            // Status bar, left/right system insets partially obscure content (padding).
            metrics.physicalPaddingTop = insets.top
            metrics.physicalPaddingRight = insets.right
            metrics.physicalPaddingBottom = 0
            metrics.physicalPaddingLeft = insets.left

            // Bottom system inset (keyboard) should adjust scrollable bottom edge (inset).
            metrics.physicalViewInsetTop = 0
            metrics.physicalViewInsetRight = 0
            metrics.physicalViewInsetBottom = insets.bottom
            metrics.physicalViewInsetLeft = 0
            true
        } else {
            super.fitSystemWindows(insets)
        }
    }

    override fun onSizeChanged(w: Int, h: Int, ow: Int, oh: Int) {
        metrics.physicalWidth = w
        metrics.physicalHeight = h
        super.onSizeChanged(w, h, ow, oh)
    }
}