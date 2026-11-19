package neko.music.dsp.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import neko.music.dsp.controller.DspController
import neko.music.dsp.controller.DspControllerImpl
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class DspModule {

  @Binds
  @Singleton
  abstract fun bindDspController(impl: DspControllerImpl): DspController
}
