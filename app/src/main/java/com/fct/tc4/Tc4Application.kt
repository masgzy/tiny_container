// Tc4Application.kt -- This file is part of tiny_container.
//
// Copyright (C) 2026 Caten Hu
//
// Tiny Container is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or any later version.
//
// Tiny Container is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.

package com.fct.tc4

import android.app.Application
import android.content.Context
import com.fct.tc4.ui.misc.Global
import com.google.android.material.color.DynamicColors

class Tc4Application : Application() {
    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this)

        Global.init(this)
        seedAvncGestureDefaults()
    }

    /**
     * 将 AVNC 的"轻按两次并滑动"手势默认动作预置为"拖动远程内容"（remote-drag）。
     *
     * AVNC 中该手势默认为 none；本应改 avnc 库默认值，但那需要分叉重新发版，
     * 故直接写入其默认偏好文件（PreferenceManager.getDefaultSharedPreferences 用的
     * 就是 <packageName>_preferences）。必须在 App 启动时尽早执行：若用户先打开
     * AVNC 手势设置界面，androidx ListPreference 可能会把 XML 默认值 none 持久化，
     * 导致之后无法区分"用户显式选择"与"未设置过"。
     * 仅在从未写入时预置一次；用户之后在 AVNC 设置里改的值始终优先。
     */
    private fun seedAvncGestureDefaults() {
        val prefs = getSharedPreferences("$packageName", Context.MODE_PRIVATE)
        if (!prefs.contains("gesture_double_tap_swipe")) {
            prefs.edit().putString("gesture_double_tap_swipe", "remote-drag").apply()
        }
    }
}
