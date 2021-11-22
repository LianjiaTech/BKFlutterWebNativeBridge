package com.example.flutter_downgrade_demo2

import android.content.Intent
import android.os.Bundle
import android.widget.AutoCompleteTextView
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
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
                if (url.isBlank()) "http://10.33.66.54/web/#/" else url,
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
