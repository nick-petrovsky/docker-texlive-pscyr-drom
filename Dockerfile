FROM danteev/texlive
MAINTAINER Nick Petrovsky
ENV DEBIAN_FRONTEND noninteractive

# Install MS fonts and wavedrom-cli
RUN sed -i'.bak' 's/$/ contrib/' /etc/apt/sources.list && \
	apt-get update -q && \
	apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends npm ttf-mscorefonts-installer fontconfig && \
	fc-cache -fv && \
	npm i wavedrom-cli -g && \
	apt-get --purge remove -qy .\*-doc$ && \
	# save some space
	rm -rf /var/lib/apt/lists/* && apt-get clean

# Install Fira Sans fonts
RUN mkdir -p /tmp/fonts && \
	cd /tmp/fonts && \
	wget "https://bboxtype.com/downloads/Fira/Download_Folder_FiraSans_4301.zip" -q && \
	wget "https://bboxtype.com/downloads/Fira/Fira_Mono_3_2.zip" -q && \
	unzip -q Download_Folder_FiraSans_4301.zip && \
	unzip -q Fira_Mono_3_2.zip && \
	mkdir -p /usr/share/fonts/truetype/FiraSans && \
	mkdir -p /usr/share/fonts/opentype/FiraSans && \
	cp Download_Folder_FiraSans_4301/Fonts/Fira_Sans_TTF_4301/*/*/*.ttf /usr/share/fonts/truetype/FiraSans/ && \
	cp Download_Folder_FiraSans_4301/Fonts/Fira_Sans_OTF_4301/*/*/*.otf /usr/share/fonts/opentype/FiraSans/ && \
	cp Fira_Mono_3_2/Fonts/FiraMono_WEB_32/*.ttf /usr/share/fonts/truetype/FiraSans && \
	cp Fira_Mono_3_2/Fonts/FiraMono_OTF_32/*.otf /usr/share/fonts/truetype/FiraSans && \
	fc-cache -f -v && \
	cd .. && \
	rm -rf fonts

# Install PSCyr
RUN TEXMF="$(kpsewhich -expand-var='$TEXMFLOCAL')" VARTEXFONTS="$(kpsewhich -expand-var='$VARTEXFONTS')" && \
	echo "###> Installing PSCyr to '$TEXMF' folder ('$VARTEXFONTS')" && \
	mkdir -p /tmp/fonts && \
	cd /tmp/fonts && \
	wget "https://github.com/senior-sigan/docker-latex/raw/master/src/PSCyr.zip" -q && \
	unzip -q /tmp/fonts/PSCyr.zip -d /tmp/fonts && \
	cd /tmp/fonts/PSCyr && \
	mkdir -p $TEXMF/tex/latex/pscyr && \
	mkdir -p $TEXMF/fonts/tfm/public/pscyr && \
	mkdir -p $TEXMF/fonts/vf/public/pscyr && \
	mkdir -p $TEXMF/fonts/type1/public/pscyr && \
	mkdir -p $TEXMF/fonts/afm/public/pscyr && \
	mkdir -p $TEXMF/doc/fonts/pscyr && \
	mkdir -p $TEXMF/fonts/enc/pscyr && \
	mkdir -p $TEXMF/fonts/map/dvips/pscyr && \
	# tweak from http://welinux.ru/post/3200/
	mkdir -p fonts/map && \
	mkdir -p fonts/enc && \
	mv dvips/pscyr/*.map fonts/map/ && \
	mv dvips/pscyr/*.enc fonts/enc/ && \
	cp fonts/enc/* $TEXMF/fonts/enc/pscyr && \
	cp fonts/map/* $TEXMF/fonts/map/dvips/pscyr && \
	# endtweak
	cp tex/latex/pscyr/* $TEXMF/tex/latex/pscyr && \
	cp fonts/tfm/public/pscyr/* $TEXMF/fonts/tfm/public/pscyr && \
	cp fonts/vf/public/pscyr/* $TEXMF/fonts/vf/public/pscyr && \
	cp fonts/type1/public/pscyr/* $TEXMF/fonts/type1/public/pscyr && \
	cp fonts/afm/public/pscyr/* $TEXMF/fonts/afm/public/pscyr && \
	cp LICENSE doc/README.koi doc/PROBLEMS $TEXMF/doc/fonts/pscyr && \
	rm -f $VARTEXFONTS/pk/modeless/public/pscyr/* && \
	# Next, we need to add pscyr to updmap.cfg
	mkdir -p $TEXMF/web2c/ && \
	echo "Map pscyr.map" >> $TEXMF/web2c/updmap.cfg && \
	echo "###> Updating file lists" && \
	mktexlsr && \
	echo "###> Running updmap" && \
	updmap-sys && \
	cd ../.. && \
	rm -rf fonts
	

# update font index
RUN luaotfload-tool --update

WORKDIR /workdir

