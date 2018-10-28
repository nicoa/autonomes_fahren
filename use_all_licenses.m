licenses = {'image_toolbox', 'matlab', 'matlab_coder', 'real-time_workshop',...
            'rtw_embedded_coder', 'simulink','video_and_image_blockset',...
            'virtual_reality_toolbox'}
no_not_licenses = checkout_licenses(licenses);
while no_not_licenses
    fprintf("%s\t no of licenses not available: %i\n",...
            datestr(datetime('now'), 31), no_not_licenses)
    pause(60)
    no_not_licenses = checkout_licenses(licenses);
end
fprintf('DONE!\n\n')
if ~no_not_licenses
    msgbox('Licenses allocated!')
end
%% checkout_licenses: function description
function [all_checked] = checkout_licenses(licenses)
    all_checked = sum((cellfun(@get_license,licenses) - 1) * (-1));
end

%% get_license: function description
function [outputs] = get_license(lic)
    [outputs, ~] = license('checkout', lic);
end
