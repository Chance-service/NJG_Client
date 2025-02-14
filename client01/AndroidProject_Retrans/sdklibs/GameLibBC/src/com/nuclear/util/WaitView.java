package com.nuclear.util;

import android.app.Activity;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
/*
 * 转菊花 add by fanghairui 20150629
 */
public class WaitView extends FrameLayout
{
  private static int BG_COLOR = 1073741824;
  private ProgressBar mProgressBar;
  private boolean mIsWaiting = false;
  private Activity mActivity;

  public WaitView(Activity _activity)
  {
    super(_activity);

    this.mActivity = _activity;

    init();
  }

  protected void init()
  {
    setLayoutParams(new FrameLayout.LayoutParams(-1, -1));

    this.mProgressBar = new ProgressBar(this.mActivity);

    FrameLayout.LayoutParams lParam = new FrameLayout.LayoutParams(-2, -2);
    lParam.gravity = 17;
    this.mProgressBar.setLayoutParams(lParam);

    setBackgroundColor(BG_COLOR);

    setOnClickListener(null);
  }

  public void show()
  {
    if (this.mIsWaiting)
    {
      return;
    }

    this.mIsWaiting = true;
    addView(this.mProgressBar);
    ((FrameLayout)this.mActivity.getWindow().getDecorView()).addView(this);
    bringToFront();
  }

  public void remove()
  {
    if (this.mIsWaiting)
    {
      this.mIsWaiting = false;

      removeAllViews();
      ((FrameLayout)this.mActivity.getWindow().getDecorView()).removeView(this);
    }
  }
}
