# Python 3 running on debian
FROM cdl-hadoop-artifactory.asml.com/docker/python:3

# Essential tools and xvfb
#   Xvfb performs all graphical operations 
#   in virtual memory without showing any screen output
RUN apt-get update && apt-get install -y \
    software-properties-common \
    unzip \
    curl \
    xvfb \
    feh

# Chrome browser to run the tests
# When stable will become newer, a drivier version has to be updated manually!
RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub -o /tmp/google.pub \
    && cat /tmp/google.pub | apt-key add -; rm /tmp/google.pub \
    && echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google.list \
    && mkdir -p /usr/share/desktop-directories \
    && apt-get -y update && apt-get install -y google-chrome-stable

# Disable the SUID sandbox so that chrome can launch without being in a privileged container
RUN dpkg-divert --add --rename --divert /opt/google/chrome/google-chrome.real /opt/google/chrome/google-chrome \
    && echo "#!/bin/bash\nexec /opt/google/chrome/google-chrome.real --no-sandbox --disable-setuid-sandbox \"\$@\"" > /opt/google/chrome/google-chrome \
    && chmod 755 /opt/google/chrome/google-chrome
 
# Chrome Driver [- 77 -]
# Change it to a newer version once Chrome stable gets updated!
RUN mkdir -p /opt/selenium \
    && curl https://chromedriver.storage.googleapis.com/77.0.3865.40/chromedriver_linux64.zip -o /opt/selenium/chromedriver_linux64.zip \
    && cd /opt/selenium; unzip /opt/selenium/chromedriver_linux64.zip; rm -rf chromedriver_linux64.zip; ln -fs /opt/selenium/chromedriver /usr/local/bin/chromedriver;

# Fix broken pakcages
RUN apt-get update --fix-missing
RUN ap-get install -f

# Update packages
RUN apt-get update

# Switch default directory
WORKDIR /app