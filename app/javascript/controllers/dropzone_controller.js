import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'
import Dropzone from 'dropzone'

export default class extends Controller {
  #initializing = false

  static values = {
    url: String,
    paramName: String,
    maxFiles: { type: Number, default: null },
    maxFilesize: { type: Number, default: 256 },
    acceptedFiles: { type: String, default: null },
    addRemoveLinks: { type: Boolean, default: true },
    message: { type: String, default: '' },
    hint: { type: String, default: '' },
    existingFiles: { type: Array, default: [] }
  }

  connect() {
    this.#initializing = true
    this.dropZone = this.#createDropZone()
    this.dropZone.enqueueFile = file => this.#upload(file)
    this.#loadExistingFiles()
    this.#initializing = false
  }

  disconnect() {
    this.dropZone.destroy()
  }

  #createDropZone() {
    const isSingleFile = this.maxFilesValue === 1

    const dz = new Dropzone(this.element, {
      url: this.urlValue,
      paramName: this.paramNameValue,
      maxFiles: isSingleFile ? null : this.maxFilesValue,
      maxFilesize: this.maxFilesizeValue,
      acceptedFiles: this.acceptedFilesValue,
      addRemoveLinks: this.addRemoveLinksValue,
      dictDefaultMessage: `<span class="dz-message-text">${this.messageValue}</span><span class="dz-message-hint">${this.hintValue}</span>`
    })

    if (isSingleFile) {
      this.#enforceSingleFileInput(dz)
    }

    dz.on('addedfile', file => {
      if (this.#initializing) return

      if (isSingleFile) {
        // Single-file: replace previous file instead of showing error
        dz.files.filter(f => f !== file).forEach(f => dz.removeFile(f))
      } else {
        // Multiple-file: reject duplicates (same name + size)
        const duplicate = dz.files.find(f => f !== file && f.name === file.name && f.size === file.size)
        if (duplicate) dz.removeFile(file)
      }
    })

    return dz
  }

  #loadExistingFiles() {
    this.existingFilesValue.forEach(fileData => {
      const mockFile = {
        name: fileData.name,
        size: fileData.size,
        accepted: true,
        status: Dropzone.SUCCESS
      }

      this.dropZone.files.push(mockFile)
      this.dropZone.emit('addedfile', mockFile)
      if (fileData.url) {
        this.dropZone.emit('thumbnail', mockFile, fileData.url)
      }
      this.dropZone.emit('complete', mockFile)

      // Hidden input with signed_id so existing files are submitted with the form
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = this.dropZone.options.paramName
      hiddenInput.value = fileData.signed_id
      mockFile.previewElement.appendChild(hiddenInput)
    })
  }

  #enforceSingleFileInput(dz) {
    // We use maxFiles=null so Dropzone allows replacing the file,
    // but that makes the OS file dialog allow multi-select.
    // Intercept the property so every hidden input Dropzone creates
    // has `multiple` removed immediately.
    let input = dz.hiddenFileInput
    if (input) input.removeAttribute('multiple')

    Object.defineProperty(dz, 'hiddenFileInput', {
      get: () => input,
      set: el => {
        input = el
        if (el) el.removeAttribute('multiple')
      }
    })
  }

  #upload(file) {
    new Uploader(file, this.dropZone).start()
  }
}

class Uploader {
  constructor(file, dropZone) {
    this.file = file
    this.dropZone = dropZone
  }

  start() {
    this.#createDirectUpload((error, blob) => {
      if (error) {
        this.#emitDropzoneError(error)
      } else {
        this.#createHiddenInput(blob.signed_id)
        this.#emitDropzoneSuccess()
      }
    })
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.file.xhr = xhr
    this.#bindProgress()
    this.#emitDropzoneProcessing()
  }

  #createDirectUpload(callback) {
    new DirectUpload(this.file, this.dropZone.options.url, this).create(callback)
  }

  #createHiddenInput(signedId) {
    this.hiddenInput = document.createElement('input')
    this.hiddenInput.type = 'hidden'
    this.hiddenInput.name = this.dropZone.options.paramName
    this.hiddenInput.value = signedId
    this.file.previewElement.appendChild(this.hiddenInput)
  }

  #bindProgress() {
    this.file.xhr.upload.addEventListener('progress', event => this.#directUploadDidProgress(event))
  }

  #directUploadDidProgress(event) {
    this.file.upload.progress = (100 * event.loaded) / event.total
    this.file.upload.total = event.total
    this.file.upload.bytesSent = event.loaded
    this.dropZone.emit('uploadprogress', this.file, this.file.upload.progress, this.file.upload.bytesSent)
  }

  #emitDropzoneProcessing() {
    this.file.status = Dropzone.PROCESSING
    this.dropZone.emit('processing', this.file)
  }

  #emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS
    this.dropZone.emit('success', this.file)
    this.dropZone.emit('complete', this.file)
  }

  #emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR
    this.dropZone.emit('error', this.file, error)
    this.dropZone.emit('complete', this.file)
  }
}
