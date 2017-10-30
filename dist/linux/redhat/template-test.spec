Name: %%PACKAGE_NAME%%
Version: %%VERSION_MAJOR%%.%%VERSION_MINOR%%
Release: %%VERSION_RELEASE%%%{?dist}
Summary: %%GAME_DESCRIPTION%%

Group: Amusements/Games
License: GPLv3
URL: https://github.com/fgagamedev/multiplatform-sdl2-project-template
Source0: %{name}.tar.gz

BuildRoot: %{_tmppath}/%{name}-root
AutoReq: no

%description
Long package description

%prep
%setup -q


%build
./scripts/build.sh release


%install
mkdir -p %{buildroot}/var/games/%%PACKAGE_NAME%%/lib
cp src/%%PACKAGE_NAME%%_release %{buildroot}/var/games/%%PACKAGE_NAME%%/%%PACKAGE_NAME%%

# Copying libraries
for extlib in `ls lib`;
do
    cp -P lib/$extlib/linux/release/*.so.* %{buildroot}/var/games/%%PACKAGE_NAME%%/lib;
done

# Removing extra symbolic links

mkdir -p %{buildroot}/var/games/%%PACKAGE_NAME%%/resources
cp -r resources/*  %{buildroot}/var/games/%%PACKAGE_NAME%%/resources/

mkdir -p %{buildroot}/usr/games/
cp -P dist/linux/redhat/%%PACKAGE_NAME%% %{buildroot}/usr/games/

mkdir -p %{buildroot}/%{_mandir}/man6
cp dist/linux/debian/%%PACKAGE_NAME%%.6 %{buildroot}/%{_mandir}/man6
gzip -9 %{buildroot}/%{_mandir}/man6/%%PACKAGE_NAME%%.6

# Set the correct permissions for shared libraries
find %{buildroot} -type f \( -name '*.so' -o -name '*.so.*' \) -exec chmod 755 {} \;

%post
/sbin/ldconfig
ln -s /usr/games/%%PACKAGE_NAME%% /usr/bin/

%postun
/sbin/ldconfig
rm /usr/bin/%%PACKAGE_NAME%%

%files
%defattr(644,root,root)
%attr(755,root,root) /usr/games/%%PACKAGE_NAME%%
%attr(755,root,root) /var/games/%%PACKAGE_NAME%%/%%PACKAGE_NAME%%
%attr(755,root,root) /var/games/%%PACKAGE_NAME%%
%attr(755,root,root) /var/games/%%PACKAGE_NAME%%/resources
%attr(755,root,root) /var/games/%%PACKAGE_NAME%%/lib
%doc %{_mandir}/man6/%%PACKAGE_NAME%%.6.gz

%changelog
* Fri Jul 21 2017 Edson Alves <edsomjr@gmail.com>  - 0.0-1%{?dist}
- Fixing several rpmlintian errors and warnings
