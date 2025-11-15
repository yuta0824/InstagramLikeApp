import * as FilePond from "filepond";
import FilePondPluginImagePreview from "filepond-plugin-image-preview";
import FilePondPluginImageExifOrientation from "filepond-plugin-image-exif-orientation";
import FilePondPluginFileValidateSize from "filepond-plugin-file-validate-size";
import FilePondPluginImageEdit from "filepond-plugin-image-edit";
import "filepond/dist/filepond.min.css";
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.min.css";
import "filepond-plugin-image-edit/dist/filepond-plugin-image-edit.min.css";

FilePond.registerPlugin(
  FilePondPluginImagePreview,
  FilePondPluginImageExifOrientation,
  FilePondPluginFileValidateSize,
  FilePondPluginImageEdit
);

export const initFilePond = () => {
  const inputElement =
    document.querySelector<HTMLInputElement>("input.filepond");
  if (!inputElement) return;
  const originalName = inputElement.getAttribute("name");

  const MAX_FILES = 3;
  const MAX_FILE_SIZE = "3MB";

  const pond = FilePond.create(inputElement, {
    allowReorder: true,
    allowMultiple: true,
    maxFileSize: MAX_FILE_SIZE,
    maxFiles: MAX_FILES,
    storeAsFile: true,
    name: originalName.replace("[]", ""),
    labelIdle: `Drag & Drop your files or <span class="filepond--label-action"> Browse </span><br><span style="font-size: 0.9em; opacity: 0.7;">Maximum ${MAX_FILES} files</span>`,
  });

  return pond;
};
