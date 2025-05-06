/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/

package org.cocos2dx.lib;

import org.cocos2dx.lib.ListenerEditText.KeyImeChange;

//noinspection SuspiciousImport
import android.R;
import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnLayoutChangeListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import java.util.Objects;

public class Cocos2dxEditBoxDialog extends Dialog {
	// ===========================================================
	// Constants
	// ===========================================================

	/**
	 * The user is allowed to enter any text, including line breaks.
	 */
	private final int kEditBoxInputModeAny = 0;

	/**
	 * The user is allowed to enter an e-mail address.
	 */
	private final int kEditBoxInputModeEmailAddr = 1;

	/**
	 * The user is allowed to enter an integer value.
	 */
	private final int kEditBoxInputModeNumeric = 2;

	/**
	 * The user is allowed to enter a phone number.
	 */
	private final int kEditBoxInputModePhoneNumber = 3;

	/**
	 * The user is allowed to enter a URL.
	 */
	private final int kEditBoxInputModeUrl = 4;

	/**
	 * The user is allowed to enter a real number value. This extends kEditBoxInputModeNumeric by allowing a decimal point.
	 */
	private final int kEditBoxInputModeDecimal = 5;

	/**
	 * The user is allowed to enter any text, except for line breaks.
	 */
	private final int kEditBoxInputModeSingleLine = 6;

	/**
	 * Indicates that the text entered is confidential data that should be obscured whenever possible. This implies EDIT_BOX_INPUT_FLAG_SENSITIVE.
	 */
	private final int kEditBoxInputFlagPassword = 0;

	/**
	 * Indicates that the text entered is sensitive data that the implementation must never store into a dictionary or table for use in predictive, auto-completing, or other accelerated input schemes. A credit card number is an example of sensitive data.
	 */
	private final int kEditBoxInputFlagSensitive = 1;

	/**
	 * This flag is a hint to the implementation that during text editing, the initial letter of each word should be capitalized.
	 */
	private final int kEditBoxInputFlagInitialCapsWord = 2;

	/**
	 * This flag is a hint to the implementation that during text editing, the initial letter of each sentence should be capitalized.
	 */
	private final int kEditBoxInputFlagInitialCapsSentence = 3;

	/**
	 * Capitalize all characters automatically.
	 */
	private final int kEditBoxInputFlagInitialCapsAllCharacters = 4;

	private final int kKeyboardReturnTypeDefault = 0;
	private final int kKeyboardReturnTypeDone = 1;
	private final int kKeyboardReturnTypeSend = 2;
	private final int kKeyboardReturnTypeSearch = 3;
	private final int kKeyboardReturnTypeGo = 4;

	// ===========================================================
	// Fields
	// ===========================================================
	public static ListenerEditText mInputEditTextRef = null;

	private ListenerEditText mInputEditText;
	private TextView mTextViewTitle;
	private Button mOkBtn;
	private Button mCancelBtn;

	private final String mTitle;
	private final String mMessage;
	private final int mInputMode;
	private final int mInputFlag;
	private final int mReturnType;
	private final int mMaxLength;

	private int mInputFlagConstraints;
	private int mInputModeContraints;
	private boolean mIsMultiline;
	private int lastHight = 0;
	private final String TAG = "Cocos2dxEditBoxDialog";
    //private Cocos2dxActivity theActivity ;
	// ===========================================================
	// Constructors
	// ===========================================================

	public Cocos2dxEditBoxDialog(final Context pContext, final String pTitle, final String pMessage, final int pInputMode, final int pInputFlag, final int pReturnType, final int pMaxLength) {
		super(pContext, android.R.style.Theme_Translucent_NoTitleBar_Fullscreen);
		this.mTitle = pTitle;
		this.mMessage = pMessage;
		this.mInputMode = pInputMode;
		this.mInputFlag = pInputFlag;
		this.mReturnType = pReturnType;
		this.mMaxLength = pMaxLength;
		
		//theActivity.SetCocos2dxEditDialog(this);
	}

	@SuppressLint("NewApi")
	@Override
	protected void onCreate(final Bundle pSavedInstanceState) {
		Log.w(TAG, "__________onCreate");
		super.onCreate(pSavedInstanceState);
		//this.getWindow().setBackgroundDrawable(new ColorDrawable(0x80000000));
		lastHight = 0;
		final LinearLayout layout = new LinearLayout(this.getContext());
		layout.setOrientation(LinearLayout.VERTICAL);

		final LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

		this.mTextViewTitle = new TextView(this.getContext());
		final LinearLayout.LayoutParams textviewParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		textviewParams.topMargin = 5000;
		textviewParams.leftMargin = textviewParams.rightMargin = this.convertDipsToPixels(10);
		this.mTextViewTitle.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 20);
		layout.addView(this.mTextViewTitle, textviewParams);

		this.mInputEditText =new ListenerEditText(this.getContext()); //(ListenerEditText) new ListenerEditText(this.getContext());
		final LinearLayout.LayoutParams editTextParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		editTextParams.leftMargin = editTextParams.rightMargin = this.convertDipsToPixels(10);
		this.mInputEditText.addOnLayoutChangeListener(new OnLayoutChangeListener() {

			@Override
			public void onLayoutChange(View arg0, int arg1, int arg2, int arg3,
					int arg4, int arg5, int arg6, int arg7, int arg8) {
				Log.w(TAG, "__________onLayoutChange");
				OnGetEditBoxHight();
			}
		});

		this.mInputEditText.setKeyImeChangeListener(new KeyImeChange(){
		    @Override
		    public void onKeyIme(int keyCode, KeyEvent event)
		    {
		    	//System.out.println("________________"+event.getKeyCode());
				Log.w(TAG, "__________onKeyIme");
		        if (KeyEvent.KEYCODE_BACK == event.getKeyCode())
		        {
		            // do something
					Log.w(TAG, "__________KEYCODE_BACK");
		        	closeKeyboard();
		        	System.out.println("________________KEYCODE_BACK");
		        }
		        if (KeyEvent.KEYCODE_MENU == event.getKeyCode())
		        {
		            // do something
					Log.w(TAG, "__________KEYCODE_MENU");
		        	closeKeyboard();
		        	System.out.println("________________KEYCODE_MENU");
		        }
		        if (KeyEvent.KEYCODE_HOME == event.getKeyCode())
		        {
		            // do something
					Log.w(TAG, "__________KEYCODE_HOME");
		        	closeKeyboard();
		        	System.out.println("________________KEYCODE_HOME");
		        }
				Log.w(TAG, "__________onKeyIme END");
		    }});

		this.mInputEditText.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
				//System.out.println("__________onTextChanged");
				Log.w(TAG, "__________onTextChanged");
				if (arg0 == null)
	                return;
				String str = arg0.toString().substring(arg1, arg1 + arg3);
	            if (str.equals("\n")) {
	            	mInputEditText.setText(arg0.toString().replaceFirst("\n", ""));
	            	Cocos2dxHelper.setEditTextDialogCancelResult(mInputEditText.getText().toString());
					Cocos2dxEditBoxDialog.this.closeKeyboard();
					//Log.e("cocos2dxDialog", "----str.equals(\n)---" + str);
					Cocos2dxEditBoxDialog.this.dismiss();
	            }
				Log.w(TAG, "__________onTextChanged END");
			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {
				Log.w(TAG, "__________beforeTextChanged");
			}

			@Override
			public void afterTextChanged(Editable arg0) {
				String txt = Cocos2dxEditBoxDialog.this.mInputEditText.getText().toString();
				Log.w(TAG, "__________afterTextChanged");
				Cocos2dxHelper.setEditTextDialogResult(txt);
				Log.w(TAG, "__________afterTextChanged END");
			}
		});
		this.mInputEditText.setSingleLine(true);
		this.mInputEditText.setInputType(EditorInfo.TYPE_CLASS_TEXT);
		this.mInputEditText.setImeOptions(EditorInfo.IME_ACTION_SEARCH);
		this.mInputEditText.setOnEditorActionListener(new OnEditorActionListener() {
			@Override
			public boolean onEditorAction(final TextView v, final int actionId, final KeyEvent event) {
				/* If user didn't set keyboard type, this callback will be invoked twice with 'KeyEvent.ACTION_DOWN' and 'KeyEvent.ACTION_UP'. */
				Log.w(TAG, "__________onEditorAction ");
				if (actionId != EditorInfo.IME_NULL || event != null && event.getAction() == KeyEvent.ACTION_DOWN) {
					//Cocos2dxHelper.setEditTextDialogResult(Cocos2dxEditBoxDialog.this.mInputEditText.getText().toString());
					Cocos2dxEditBoxDialog.this.closeKeyboard();
					Cocos2dxEditBoxDialog.this.dismiss();
					return true;
				}
				return false;
			}
		});
		layout.addView(this.mInputEditText, editTextParams);

		{
			final LinearLayout layout1 = new LinearLayout(this.getContext());
			layout1.setOrientation(LinearLayout.HORIZONTAL);
			
			final LinearLayout.LayoutParams ltParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
			
			layout.addView(layout1, ltParams);
			
			final LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
			btnParams.leftMargin = this.convertDipsToPixels(10);
			
			int iOne = (int) ((this.getContext().getResources().getDisplayMetrics().widthPixels-2*btnParams.leftMargin) * 0.1);
			
			btnParams.rightMargin = iOne/2;
			btnParams.topMargin = btnParams.bottomMargin = this.convertDipsToPixels(10);
			this.mOkBtn = new Button(this.getContext());
			this.mOkBtn.setText(R.string.ok);
			this.mOkBtn.setWidth((int) (iOne*4.5));
			layout1.addView(this.mOkBtn, btnParams);
			
			final LinearLayout.LayoutParams btnParams1 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
			btnParams1.leftMargin = iOne/2;
			btnParams1.rightMargin = btnParams.leftMargin;
			btnParams1.topMargin = btnParams1.bottomMargin = this.convertDipsToPixels(10);
			this.mCancelBtn = new Button(this.getContext());
			this.mCancelBtn.setText(R.string.cancel);
			this.mCancelBtn.setWidth((int) (iOne*4.5));
			layout1.addView(this.mCancelBtn, btnParams1);
			
			this.mOkBtn.setOnClickListener(new View.OnClickListener()
			{

				@Override
				public void onClick(View v) {
					Log.w(TAG, "__________onClick");
					//String txt = Cocos2dxEditBoxDialog.this.mInputEditText.getText().toString();
					//
					//if (!txt.isEmpty())
					//	Cocos2dxHelper.setEditTextDialogResult(txt);
					Cocos2dxEditBoxDialog.this.closeKeyboard();
					//Log.e("cocos2dxDialog", "-----this.mOkBtn.setOnClickListener");
					Cocos2dxEditBoxDialog.this.dismiss();
					Log.w(TAG, "__________onClick END");
				}
				
			});
			
			this.mCancelBtn.setOnClickListener(new View.OnClickListener()
			{

				@Override
				public void onClick(View v) {
					Log.w(TAG, "__________onClick2");
					String txt = Cocos2dxEditBoxDialog.this.mInputEditText.getText().toString();
					//
					if (!txt.isEmpty())
						Cocos2dxHelper.setEditTextDialogCancelResult(txt);
					Cocos2dxEditBoxDialog.this.closeKeyboard();
					//Log.e("cocos2dxDialog", "-----this.mCancelBtn.setOnClickListener");
					Cocos2dxEditBoxDialog.this.dismiss();
					Log.w(TAG, "__________onClick2 END");
				}
				
			});

		}
		

		this.setContentView(layout, layoutParams);

		Objects.requireNonNull(this.getWindow()).addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

		this.mTextViewTitle.setText(this.mTitle);
		this.mInputEditText.setText(this.mMessage);

		int oldImeOptions = this.mInputEditText.getImeOptions();
		this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_FLAG_NO_EXTRACT_UI);
		oldImeOptions = this.mInputEditText.getImeOptions();

		switch (this.mInputMode) {
			case kEditBoxInputModeAny:
				this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
				break;
			case kEditBoxInputModeEmailAddr:
				this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
				break;
			case kEditBoxInputModeNumeric:
				this.mInputModeContraints = InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_SIGNED;
				break;
			case kEditBoxInputModePhoneNumber:
				this.mInputModeContraints = InputType.TYPE_CLASS_PHONE;
				break;
			case kEditBoxInputModeUrl:
				this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI;
				break;
			case kEditBoxInputModeDecimal:
				this.mInputModeContraints = InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL | InputType.TYPE_NUMBER_FLAG_SIGNED;
				break;
			case kEditBoxInputModeSingleLine:
				this.mInputModeContraints = InputType.TYPE_CLASS_TEXT;
				break;
			default:

				break;
		}

		if (this.mIsMultiline) {
			this.mInputModeContraints |= InputType.TYPE_TEXT_FLAG_MULTI_LINE;
		}

		this.mInputEditText.setInputType(this.mInputModeContraints | this.mInputFlagConstraints);

		switch (this.mInputFlag) {
			case kEditBoxInputFlagPassword:
				this.mInputFlagConstraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD;
				break;
			case kEditBoxInputFlagSensitive:
				this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
				break;
			case kEditBoxInputFlagInitialCapsWord:
				this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_WORDS;
				break;
			case kEditBoxInputFlagInitialCapsSentence:
				this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_SENTENCES;
				break;
			case kEditBoxInputFlagInitialCapsAllCharacters:
				this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS;
				break;
			default:
				break;
		}

		this.mInputEditText.setInputType(this.mInputFlagConstraints | this.mInputModeContraints);

		switch (this.mReturnType) {
			case kKeyboardReturnTypeDefault:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_NONE);
				break;
			case kKeyboardReturnTypeDone:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_DONE);
				break;
			case kKeyboardReturnTypeSend:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_SEND);
				break;
			case kKeyboardReturnTypeSearch:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_SEARCH);
				break;
			case kKeyboardReturnTypeGo:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_GO);
				break;
			default:
				this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_NONE);
				break;
		}

		if (this.mMaxLength > 0) {
			this.mInputEditText.setFilters(new InputFilter[] { new InputFilter.LengthFilter(this.mMaxLength) });
		}

		final Handler initHandler = new Handler();
		initHandler.postDelayed(new Runnable() {
			@Override
			public void run() {
				Log.w(TAG, "__________postDelayed RUN");
				Cocos2dxEditBoxDialog.this.mInputEditText.requestFocus();
				Cocos2dxEditBoxDialog.this.mInputEditText.setSelection(Cocos2dxEditBoxDialog.this.mInputEditText.length());
				Cocos2dxEditBoxDialog.this.openKeyboard();
				Log.w(TAG, "__________postDelayed RUN END");
			}
		}, 200);

		
		this.mTextViewTitle.setEnabled(false);
		this.mCancelBtn.setVisibility(View.GONE);
		this.mOkBtn.setVisibility(View.GONE);
		mInputEditTextRef = this.mInputEditText;

		Log.w(TAG, "__________onCreate END");
	}

	@SuppressLint({"NewApi", "SuspiciousIndentation"})
	public void OnGetEditBoxHight() {
		Log.w(TAG, "__________OnGetEditBoxHight");
		WindowManager  wm = (WindowManager) Cocos2dxEditBoxDialog.this.getContext().getSystemService(Context.WINDOW_SERVICE);
		
	    Point outSize = new Point();
	    wm.getDefaultDisplay().getRealSize(outSize);
		int y = outSize.y;
		Rect r = new Rect();
        Objects.requireNonNull(getWindow()).getDecorView().getWindowVisibleDisplayFrame(r);
        int dif = y - r.height();
        if(dif != lastHight) 
        {
        	if(lastHight>0 && (dif == 0))
        	{
				Log.w(TAG, "__________closeKeyboard");
        		closeKeyboard();
				Log.w(TAG, "__________closeKeyboard2");
        	}
        	else
        	{
        		lastHight = dif;
            	//native
				Log.w(TAG, "__________UpdateKeyboardHight");
        		Cocos2dxHelper.UpdateKeyboardHight(dif);
				Log.w(TAG, "__________UpdateKeyboardHight2");
        	}
        }
		Log.w(TAG, "__________OnGetEditBoxHight END");
	}
	@Override 
    public boolean onTouchEvent(MotionEvent event) {
		//Log.w(TAG, "__________onTouchEvent " + event.getAction());
		//System.out.println("____________");
		//System.out.println(event.getAction());
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            //Cocos2dxHelper.setEditTextDialogResult(Cocos2dxEditBoxDialog.this.mInputEditText.getText().toString());
			Cocos2dxEditBoxDialog.this.closeKeyboard();
			Cocos2dxEditBoxDialog.this.dismiss();
        }
		//Log.w(TAG, "__________onTouchEvent END");
        return super.onTouchEvent(event);
    }
	private int convertDipsToPixels(final float pDIPs) {
		Log.w(TAG, "__________convertDipsToPixels");
		final float scale = this.getContext().getResources().getDisplayMetrics().density;
		Log.w(TAG, "__________convertDipsToPixels END");
		return Math.round(pDIPs * scale);
	}

	private void openKeyboard() {
		Log.e("cocos2dxDialog", "---openKeyboard-------");
		final InputMethodManager imm;
		if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.CUPCAKE) {
			imm = (InputMethodManager) this.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.showSoftInput(this.mInputEditText, 0);
		}
		Cocos2dxHelper.EditopenKeyboard();
		OnGetEditBoxHight();
		Log.e("cocos2dxDialog", "---openKeyboard END-------");
	}

	public  void closeKeyboard() {
		
		Log.e("cocos2dxDialog", "---closeKeyboard-------");
		Cocos2dxHelper.EditcloseKeyboard();
		final InputMethodManager imm;
		if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.CUPCAKE) {
			imm = (InputMethodManager) this.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.hideSoftInputFromWindow(this.mInputEditText.getWindowToken(), 0);
		}
		mInputEditTextRef = null;
		Log.e("cocos2dxDialog", "---closeKeyboard END-------");
	}

	public static void setEditBoxText(String pText) {
		Log.e("cocos2dxDialog", "---setEditBoxText-------");
		if(mInputEditTextRef !=null )
		{
			mInputEditTextRef.setText(pText);
			mInputEditTextRef.setSelection(mInputEditTextRef.length());
		}
		Log.e("cocos2dxDialog", "---setEditBoxText END-------");
	}
}
