/***************************************************************************
 * Copyright (C) 2022 Kieker (https://kieker-monitoring.net)

 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/
package moobench.tools.results;

import java.nio.file.Path;

import com.beust.jcommander.JCommander;

import kieker.common.configuration.Configuration;
import kieker.common.exception.ConfigurationException;
import kieker.tools.common.AbstractService;

/**
 * Integrate new measurements into the YAML log and create derived outputs: HTML tables and
 * JSON files for measruement overview and mean execution time graphs, respectively.
 *
 * @author Reiner Jung
 * @since 1.3.0
 *
 */
public class CompileResultsMain extends AbstractService<TeetimeConfiguration, Settings> {

    public static void main(final String[] args) {
        final CompileResultsMain main = new CompileResultsMain();
        System.exit(main.run("compile-result", "Compile Results", args, new Settings()));
    }

    @Override
    protected TeetimeConfiguration createTeetimeConfiguration() throws ConfigurationException {
        return new TeetimeConfiguration(this.settings);
    }

    @Override
    protected Path getConfigurationPath() {
        return null;
    }

    @Override
    protected boolean checkConfiguration(final Configuration configuration, final JCommander commander) {
        return true;
    }

    @Override
    protected boolean checkParameters(final JCommander commander) throws ConfigurationException {
        for (final Path inputPath : this.settings.getInputPaths()) {
            if (!inputPath.toFile().isFile() || !inputPath.toFile().exists()) {
                this.logger.error("Cannot read input file {}", inputPath.toString());
                return false;
            }
        }
        return true;
    }

    @Override
    protected void shutdownService() {
    }
}
