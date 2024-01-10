%define name jupyter-electron-app
%define version 1.0.0
%define release 1

Summary: Electron Jupyter Wrapper
Name: %{name}
Version: %{version}
Release: %{release}
License: Your License
Group: Applications/Internet
Source0: %{name}-%{version}.tar.gz

BuildArch: noarch

%description
Your Electron App Description.

%prep
%autosetup

%install
install -m 0755 -d %{buildroot}/opt
cp -a %{buildroot}/opt /opt

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(777, root, root) /opt/yourapp
