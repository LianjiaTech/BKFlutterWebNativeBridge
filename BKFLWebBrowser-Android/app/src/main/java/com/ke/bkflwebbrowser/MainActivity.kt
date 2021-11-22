package com.ke.bkflwebbrowser

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.AutoCompleteTextView
import android.widget.Button
import com.beike.flutterweb.FlutterWebActivity
import com.beike.flutterweb.utils.TransformUtils

class MainActivity : AppCompatActivity() {
    private val mUrlParams: MutableMap<String?, Any> = hashMapOf()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val autoText = findViewById<AutoCompleteTextView>(R.id.autoCompleteTextView)
        val jumpFlutterWeb = findViewById<Button>(R.id.jump_flutter_web)
        jumpFlutterWeb.setOnClickListener {
            val url = autoText.text.toString()
            navigateToWeb(
                if (url.isBlank()) "beikeft://secondhouse/myprofile/nickname" else url,
                mUrlParams
            )
        }
    }

    private fun navigateToWeb(flutterUrl: String, urlParams: Map<String?, Any>?) {
        val bundle = TransformUtils.map2Bundle(urlParams);
        bundle.putString("flutter_url", flutterUrl);
        val intent = Intent(this@MainActivity, FlutterWebActivity::class.java)
        intent.putExtras(bundle);
        startActivity(intent);
    }
}