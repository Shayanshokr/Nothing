from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, ContextTypes, filters
import requests
from bs4 import BeautifulSoup
import os
# تابع استخراج لینک دانلود از سایت ثالث (اینجا از igram.io استفاده می‌کنیم)
def get_media_url(insta_url):
    session = requests.Session()
    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    # ارسال درخواست به سایت igram.io
    response = session.post("https://igram.io/i/", data={"url": insta_url}, headers=headers)

    soup = BeautifulSoup(response.text, "html.parser")
    # استخراج لینک ویدیو یا تصویر
    video_tag = soup.find("video")
    img_tag = soup.find("img", {"class": "img-fluid"})

    if video_tag:
        return video_tag.get("src")
    elif img_tag:
        return img_tag.get("src")
    else:
        return None

# هندلر start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("سلام! لینک پست اینستاگرامی رو بفرست تا فایلش رو بفرستم 🎥📸")

# هندلر دریافت پیام (لینک)
async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text

    if "instagram.com" in text:
        await update.message.reply_text("🔄 در حال دریافت فایل از اینستاگرام...")
        media_url = get_media_url(text)

        if media_url:
            # بررسی نوع فایل
            if ".mp4" in media_url:
                await update.message.reply_video(media_url)
            else:
                await update.message.reply_photo(media_url)
        else:
            await update.message.reply_text("❌ نتونستم فایل رو پیدا کنم. لینک رو چک کن یا بعداً امتحان کن.")
    else:
        await update.message.reply_text("لطفاً فقط لینک یک پست اینستاگرامی ارسال کن.")

# راه‌اندازی ربات
def main():
    TOKEN = os.getenv("BOT_TOKEN")
    app = ApplicationBuilder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    print("🤖 ربات فعال شد...")
    app.run_polling()

if __name__ == '__main__':
    main()
