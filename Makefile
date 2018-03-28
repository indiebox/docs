# Makefile for ubos.net

UBOS_AWS_IMAGE_URL = https://console.aws.amazon.com/ec2/v2/home?region=us-east-1\#LaunchInstanceWizard:ami=ami-8a14e4f7

# ubos.net variables
STAGEDIR = stage
CACHEDIR = cache

# You can set these variables from the command line.
SPHINXOPTS    = -v
DOCTREEDIR    = $(CACHEDIR)/doctrees

ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source

.PHONY: all clean jekyll sphinx open

all: jekyll sphinx static

clean:
	rm -rf $(STAGEDIR)/* $(CACHEDIR)/*

sphinx:
	sphinx-build -b html -d $(DOCTREEDIR) $(PHINXOPTS) sphinx $(STAGEDIR)/docs

jekyll:
	jekyll build -s jekyll -d $(STAGEDIR)

static:
	[ -d "reveal/git" ] || echo "WARNING: revealjs github repo not present at ./reveal"
	install -m644 images/logo2/ubos-16x16.ico $(STAGEDIR)/favicon.ico
	[ -d "$(STAGEDIR)/files" ]  || mkdir "$(STAGEDIR)/files"
	[ -d "$(STAGEDIR)/slides" ] || mkdir "$(STAGEDIR)/slides"
	[ -d "$(STAGEDIR)/assets" ] || mkdir "$(STAGEDIR)/assets"
	[ -d "$(STAGEDIR)/assets/reveal" ] || mkdir "$(STAGEDIR)/assets/reveal"
	install -m644 files/* $(STAGEDIR)/files/
	cp -r slides/* $(STAGEDIR)/slides/
	cp -r assets/fonts $(STAGEDIR)/assets/
	cp -r assets/reveal/{css,js,lib,plugin} $(STAGEDIR)/assets/reveal/
	install -m644 images/logo2/ubos-50x50.png $(STAGEDIR)/images/
	echo 'RedirectMatch /survey https://www.surveymonkey.com/s/FVNSNYN' > $(STAGEDIR)/.htaccess
	echo 'RedirectMatch /staff(.*)$$ https://ubos.net/docs/users/shepherd-staff.html' >> $(STAGEDIR)/.htaccess
	mkdir -p $(STAGEDIR)/include
	sed -e "s!UBOS_AWS_IMAGE_URL!$(UBOS_AWS_IMAGE_URL)!g" include/amazon-ec2-image-latest.js > $(STAGEDIR)/include/amazon-ec2-image-latest.js

open:
	open -a Firefox http://localhost/
